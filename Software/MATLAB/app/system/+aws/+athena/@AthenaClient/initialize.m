function initialize(obj, varargin)
    % INITIALIZE Method to initialize the client handle.
    %
    % This method is used for initializing the AhtenaClient object. 
    % When used without arguments, it will use the default AWS Credentials
    % Provider and the default Region, by using the corrsponding chains.
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
           
    % Copyright 2018-2019 The MathWorks, Inc.
    
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
    
    if nargin > 1
    end
    
    obj.Handle = builder.build();
    
end
