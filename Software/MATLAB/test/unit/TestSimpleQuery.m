classdef TestSimpleQuery < matlab.unittest.TestCase
    % TESTCLIENT Unit Test for the Amazon Athena Client
    %
    % The test suite exercises the basic operations on the Athena Client.
    
    % Copyright 2018-2021 The MathWorks, Inc.
    
    properties
        logObj
        dbName = 'myairlines.airlines';
        % held in us-west-2
        resultBucket = 's3://athenapspunittest/airlineresult';
    end
    
    methods (TestMethodSetup)
        function testSetup(testCase)
            testCase.logObj = Logger.getLogger();
            testCase.logObj.DisplayLevel = 'verbose';
            
        end
    end
    
    methods (TestMethodTeardown)
        function testTearDown(testCase) %#ok<MANU>
            
        end
    end
    
    methods (Test)
        function testConstructor(testCase)
            write(testCase.logObj,'debug','Testing testConstructor');
            % Create the object
            athena = aws.athena.AthenaClient();
            
            testCase.verifyClass(athena,'aws.athena.AthenaClient');
        end
        
        function testInitialization(testCase)
            write(testCase.logObj,'debug','Testing testInitialization');
            % Create the client and initialize
            athena = aws.athena.AthenaClient();
            if testCase.isOnGitlab
                doAlternativeInitialize(testCase, athena)
            else
                athena.initialize();
            end
            
            testCase.verifyNotEmpty(athena.Handle);
            athena.shutdown();
            
            testCase.verifyEmpty(athena.Handle);
        end
        
        function testProxyInvalid(testCase)
            write(testCase.logObj,'debug','Testing testProxyInValid');
            % Create the client and initialize
            athena = aws.athena.AthenaClient();
            
            athena.ProxyConfiguration.host = 'myproxy.example.com';
            athena.ProxyConfiguration.port = 8080;
            
            if testCase.isOnGitlab
                doAlternativeInitialize(testCase, athena)
            else
                athena.initialize();
            end
            
            try
                
                athena.Database = testCase.dbName;
                distLimit = 1000;
                queryStr = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
                    testCase.dbName, distLimit);
                testCase.verifyError(@()athena.submitQuery(queryStr, testCase.resultBucket), 'MATLAB:Java:GenericException');
                
                testCase.verifyNotEmpty(athena.Handle);
                athena.shutdown();
                testCase.verifyEmpty(athena.Handle);
            catch ME
                testCase.verifyTrue(false, sprintf("Error occured: %s\n", ME.message));
            end
            
            % Clear proxy values in Java
            java.lang.System.clearProperty("http.proxyHost");
            java.lang.System.clearProperty("http.proxyPort");
            java.lang.System.clearProperty("http.proxyUser");
            java.lang.System.clearProperty("http.proxyPassword");
            
        end
        
        function testProxyValid(testCase)
            write(testCase.logObj,'debug','Testing testProxyValid');
            athena = aws.athena.AthenaClient();
            
            athena.ProxyConfiguration.host = getenv('TEST_PROXY');
            testCase.assertNotEmpty(athena.ProxyConfiguration.host, 'There must be a TEST_PROXY environment varaible present for proxy testing');
            athena.ProxyConfiguration.port = str2double(getenv('TEST_PROXY_PORT'));
            testCase.assertNotEmpty(athena.ProxyConfiguration.port, 'There must be a TEST_PROXY_PORT environment varaible present for proxy testing');

            if testCase.isOnGitlab
                doAlternativeInitialize(testCase, athena);
            else
                athena.initialize();
            end
            
            try
                athena.Database = testCase.dbName;
                distLimit = 1000;
                queryStr = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
                    testCase.dbName, distLimit);
                resultID = athena.submitQuery(queryStr, testCase.resultBucket);
                
                testCase.verifyNotEmpty(resultID);
                
                testCase.verifyNotEmpty(athena.Handle);
                athena.shutdown();
                
                testCase.verifyEmpty(athena.Handle);
            catch ME
                testCase.verifyTrue(false, sprintf("Error occured: %s\n", ME.message));
            end
            
            % Clear proxy values in Java
            java.lang.System.clearProperty("http.proxyHost");
            java.lang.System.clearProperty("http.proxyPort");
            java.lang.System.clearProperty("http.proxyUser");
            java.lang.System.clearProperty("http.proxyPassword");
        end
        
        function fullTest(testCase)
            write(testCase.logObj,'debug','Testing fullTest');
            % Create the client and initialize
            
            athena = aws.athena.AthenaClient();
            athena.Database = testCase.dbName;
            
            if testCase.isOnGitlab
                doAlternativeInitialize(testCase, athena)
            else
                athena.initialize();
            end
            testCase.verifyNotEmpty(athena.Handle);
            
            % createDBSQL = dbCreateSQL(tableName, srcBucket);
            
            queryStr = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
                athena.Database, 1000);
            [queryId, queryStatus] = syncSubmitQuery(athena, ...
                queryStr, testCase.resultBucket); %#ok<ASGLU>
            testCase.verifyEqual(queryStatus, 'SUCCEEDED', ...
                sprintf('The query should be SUCCEEDED, was %s', queryStatus));
            
            athena.shutdown();
            
        end
    end
    
    % Helper methods
    methods
        function doAlternativeInitialize(testCase, ath)
            % Configure values before running local test e.g.:
            % setenv('AWS_DEFAULT_REGION', 'us-west-2');
            % setenv('AWS_ACCESS_KEY_ID', 'AS<REDACTED>7');
            % setenv('AWS_SECRET_ACCESS_KEY', 'YB<REDACTED>h');
            
            reg = getenv('AWS_DEFAULT_REGION');
            testCase.assertNotEmpty(reg, 'There must be a AWS_DEFAULT_REGION environment varaible present for local testing');
            if ~strcmpi(reg, 'us-west-2')
                warning('Default unit test data held in: us-west-2, use this region');
            end
            awsKeyId = getenv('AWS_ACCESS_KEY_ID');
            testCase.assertNotEmpty(awsKeyId, 'There must be a AWS_ACCESS_KEY_ID environment varaible present for local testing');
            awsSecretKey = getenv('AWS_SECRET_ACCESS_KEY');
            testCase.assertNotEmpty(awsSecretKey, 'There must be a AWS_SECRET_ACCESS_KEY environment varaible present for local testing');
             
            cp = aws.auth.CredentialProvider.getBasicCredentialProvider(awsKeyId, awsSecretKey);
            cls = 'software.amazon.awssdk.auth.credentials.StaticCredentialsProvider';
            testCase.assertClass(cp, cls, sprintf('The CredentialsProvider should be of type "%s"\n', cls));
            ath.initialize('credentialsprovider', cp, 'region', reg);
            
        end
        
        function ret = isOnGitlab(~)
            host=getenv('CI_RUNNER_DESCRIPTION');
            ret = ~isempty(host);
        end
    end
    
end

function [queryId, S] = syncSubmitQuery(ath, queryStr, resultBucket)
    
    queryId = ath.submitQuery(queryStr, resultBucket);
    
    queryStatus = ath.getStatusOfQuery(queryId);
    while true
        % QUEUED | RUNNING | SUCCEEDED | FAILED | CANCELLED
        S = char(queryStatus.toString);
        switch S
            case {'QUEUED', 'RUNNING'}
                pause(1);
                queryStatus = ath.getStatusOfQuery(queryId);
            otherwise
                break;
        end
    end
end

