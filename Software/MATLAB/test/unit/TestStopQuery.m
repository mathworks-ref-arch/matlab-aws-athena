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
        function testTearDown(testCase)
            
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

            queryStatus = athena.getStatusOfQuery(queryId);
            
            [stopStatus, stopMsg] = athena.stopQueryExecution(queryId);
            queryStatus2 = athena.getStatusOfQuery(queryId);
            
            testCase.verifyEqual(char(queryStatus2.toString), 'CANCELLED');
            testCase.verifyEqual(stopStatus, true);
            testCase.verifyClass(stopMsg, 'java.util.Optional');
            testCase.verifyEqual(char(stopMsg.toString), 'Optional[OK]');
            athena.shutdown();
            
        end
    end
    
    % Helper methods
    methods
        function doAlternativeInitialize(testCase, ath)
            reg = getenv('AWS_DEFAULT_REGION')
            awsKeyId = getenv('AWS_ACCESS_KEY_ID')
            awsSecretKey = getenv('AWS_SECRET_ACCESS_KEY')
            
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

