function initialize(obj, varargin)
    % INITIALIZE Method to initialize the client handle.
    %
    % This method is used for initializing the AthenaClient object.
    % When used without arguments, it will use the default AWS Credentials
    % Provider and the default Region, by using the corresponding chains.
    %
    %   ath.initialize()
    %
    % To specify details, use named arguments.
    %
    %  To specify a region:
    %   ath.initialize('region', 'eu-central-1')
    %
    %  To specify a credentialsprovider
    %   ath.initialize('credentialsprovider', ...
    %      aws.auth.CredentialProvider.getBasicCredentialProvider('myid', 'mykey'));
    %
    %  The two can also be combined if necessary.
    
    % Copyright 2018-2021 The MathWorks, Inc.
    
    import software.amazon.awssdk.services.athena.AthenaClient
    import software.amazon.awssdk.regions.providers.DefaultAwsRegionProviderChain
    import software.amazon.awssdk.regions.GeneratedServiceMetadataProvider
    
    parser = inputParser();
    addParameter(parser, 'credentialsprovider', []);
    addParameter(parser, 'region', []);
    
    parser.parse(varargin{:});
    
    % Create a logger object
    logObj = Logger.getLogger();
    write(logObj,'debug','Initializing Athena client');
    
    % Configure log4j if a properties file exists
    % append the properties file location and configure it
    % This is used by the SDK for logging
    log4jPropertiesPath = fullfile(fileparts(fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))))), 'lib', 'jar', 'log4j.properties');
    if exist(log4jPropertiesPath, 'file') == 2
        org.apache.log4j.PropertyConfigurator.configure(log4jPropertiesPath);
    else
        write(logObj,'warning',['log4j.properties file not found: ', log4jPropertiesPath]);
    end

    % Ensure that proxy settings are configured if required
    % Direct Client configuration overrides MATLAB preferences if set
    useMATLABProxyPrefs(obj);
    
    builder = AthenaClient.builder();
    if ~isempty(parser.Results.credentialsprovider)
        builder.credentialsProvider(parser.Results.credentialsprovider);
    end
    
    if ~isempty(parser.Results.region)
        region = parser.Results.region;
        if ischar(region)
            import software.amazon.awssdk.regions.Region
            region = Region.of(region);
        end
    else
        rpc = DefaultAwsRegionProviderChain();
        region = rpc.getRegion();
    end
    
    smdp = GeneratedServiceMetadataProvider();
    amd = smdp.serviceMetadata('athena');
    if ~amd.regions.contains(region)
        error('AWS Athena Service is not available in region "%s".\n', region.toString());
    end
    builder.region(region);
    
    % Configure an apache http client if need for proxy support
    httpClientBuilder = configProxyHttpClient(obj);
    if ~isempty(httpClientBuilder)
        builder.httpClientBuilder(httpClientBuilder);
    end
    
    obj.Handle = builder.build();
    
end


function httpClientBuilder = configProxyHttpClient(obj)
    % By returning a builder to the upstream build the http client will be
    % automatically closed
    
    if strlength(obj.ProxyConfiguration.host) > 0
        % Only use the true option for now, false retained for further work
        useSystemDefault = true;
        
        if useSystemDefault
            % Set system properties and have them picked up by the default
            % ProxyConfiguration builder
            java.lang.System.setProperty("http.proxyHost", obj.ProxyConfiguration.host);
            java.lang.System.setProperty("http.proxyPort", num2str(obj.ProxyConfiguration.port));
            if strlength(obj.ProxyConfiguration.username) > 0
                java.lang.System.setProperty("http.proxyUser", obj.ProxyConfiguration.username);
                java.lang.System.setProperty("http.proxyPassword", obj.ProxyConfiguration.password);
            end
            proxyConfig = software.amazon.awssdk.http.apache.ProxyConfiguration.builder().build();
        else
            % Use non system host and port, not supported by Apache client, not clear why this does not work?
            proxyURI = java.net.URI([obj.ProxyConfiguration.host,':',num2str(obj.ProxyConfiguration.port)]); %#ok<UNRCH>
            proxyConfigBuilder = software.amazon.awssdk.http.apache.ProxyConfiguration.builder();
            if strlength(obj.ProxyConfiguration.username) > 0
                % Don't try to set empty values
                proxyConfigBuilder.username(obj.ProxyConfiguration.username);
                proxyConfigBuilder.password(obj.ProxyConfiguration.password);
            end
            proxyConfigBuilder.useSystemPropertyValues(java.lang.Boolean(false));
            proxyConfigBuilder.nonProxyHosts(java.util.Collections.emptySet)
            proxyConfig = proxyConfigBuilder.endpoint(proxyURI).build();
        end
        
        % Create a http client that supports proxy capability
        httpClientBuilder = software.amazon.awssdk.http.apache.ApacheHttpClient.builder();
        httpClientBuilder.proxyConfiguration(proxyConfig);
    else
        % If no apache client is required i.e. no proxy then return an empty
        httpClientBuilder = [];
    end
end % function


function useMATLABProxyPrefs(obj)
    % If the client's ProxyConfiguration host field is set already use it
    % otherwise if the MATLAB proxy preference host field is set use it
    % otherwise do nothing
    
    if strlength(obj.ProxyConfiguration.host) == 0
        % Ensure the Java proxy settings are set
        com.mathworks.mlwidgets.html.HTMLPrefs.setProxySettings; %#ok<JAPIMATHWORKS>
        % Obtain the proxy information for a given URL, OS may provide
        % different proxy for different URL expecting a common host for all
        % Athena endpoints is reasonable
        url = java.net.URL('https://athena.us-west-2.amazonaws.com');
        % This function goes to MATLAB's preference panel or if not set and on
        % Windows the system preferences
        javaProxy = com.mathworks.webproxy.WebproxyFactory.findProxyForURL(url); %#ok<JAPIMATHWORKS>
        
        if ~isempty(javaProxy)
            if strlength(char(javaProxy.address.toString)) > 0
                address = javaProxy.address;
                if isa(address,'java.net.InetSocketAddress') && ...
                        javaProxy.type == javaMethod('valueOf','java.net.Proxy$Type','HTTP')
                    % A proxy host could be determined from MATLAB preferences or OS (Windows)
                    obj.ProxyConfiguration.host = char(address.getHostName());
                    obj.ProxyConfiguration.port = address.getPort();
                    
                    mwt = com.mathworks.net.transport.MWTransportClientPropertiesFactory.create(); %#ok<JAPIMATHWORKS>
                    if strlength(char(mwt.getProxyHost())) > 0
                        obj.ProxyConfiguration.password = char(mwt.getProxyPassword());
                        obj.ProxyConfiguration.username = char(mwt.getProxyUser());
                    end
                end
            end
        end
    end
    
end % function
