classdef TestStopQuery < matlab.unittest.TestCase
    % TestStopQuery Testing the stop query functionalyt.
    %
    % The test suite exercises the basic operations on the Athena Client.
    
    % Copyright 2021 The MathWorks, Inc.
    
    properties
        logObj
        dbName = 'myairlines.airlines';
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
        
        
        function stopQueryTest(testCase)
            write(testCase.logObj,'debug','Testing stopQueryTest');
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

            queryId = athena.submitQuery(queryStr, testCase.resultBucket);

            queryStatus = athena.getStatusOfQuery(queryId); %#ok<NASGU>
            
            [stopStatus, stopMsg] = athena.stopQueryExecution(queryId);
            queryStatus2 = athena.getStatusOfQuery(queryId);
            
            testCase.verifyEqual(char(queryStatus2.toString), 'CANCELLED');
            testCase.verifyEqual(stopStatus, true);
            testCase.verifyClass(stopMsg, 'java.util.Optional');
            
            testCase.verifyTrue(strcmp(char(stopMsg.toString), 'Optional[OK]') || strcmp(char(stopMsg.toString), 'Optional[]'));
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

function [queryId, S] = syncSubmitQuery(ath, queryStr, resultBucket) %#ok<DEFNU>
    
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

