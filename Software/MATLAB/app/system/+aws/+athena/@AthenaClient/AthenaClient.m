classdef AthenaClient < aws.Object
    % CLIENT Object to represent an AWS Athena client
    % The client is used to carry out operations with the Athena service
    %
    % Example:
    %    % Create client
    %    ath = aws.athena.AthenaClient;
    %    % Set the database
    %    ath.Database = 'Airlines';
    %    % Initialize the client
    %    ath.initialize();
    %    % Use the client to carry out queries on Athena
    %    query = SELECT UniqueCarrier, distance FROM Airlines WHERE distance > 500;';
    %    queryId = ath.submitQuery(query, 's3://results/airlinesresults');
    %    % Shutdown the client when no longer needed
    %    ath.shutdown();
    
    % Copyright 2018-2021 The MathWorks, Inc.
    
    properties
        ProxyConfiguration = struct('host', '', 'port', [], 'password', '', 'username', '');
        Database = '';
        TimeOut = 10000;
    end
    
    methods
        % Constructor
        function obj = AthenaClient(varargin)
            logObj = Logger.getLogger();
            logObj.MsgPrefix = 'AWS:Athena';
            % default is debug
            % logObj.DisplayLevel = 'debug';

            write(logObj,'verbose','Creating Client');
            % error if JVM is not enabled or MATLAB is too old
            if ~usejava('jvm')
                write(logObj,'error','MATLAB must be used with the JVM enabled to access AWS Athena');
            end
            if verLessThan('matlab','9.3') % R2017a
                write(logObj,'error','MATLAB Release 2017b or newer is required');
            end

        end
        
        
        function delete(obj)
            shutdown(obj);
        end
        
    end
    
end
