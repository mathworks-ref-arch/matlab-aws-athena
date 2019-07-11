classdef TestSimpleQuery < matlab.unittest.TestCase
    % TESTCLIENT Unit Test for the Amazon Athena Client
    %
    % The test suite exercises the basic operations on the Athena Client.
    
    % Copyright 2018-2019 The MathWorks, Inc.
    
    properties
        logObj
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
        
        function fullTest(testCase)
            write(testCase.logObj,'debug','Testing fullTest');
            % Create the client and initialize
            
            % dbName = 'testdb';
            % tableName = 'newtable';
            dbName = 'MyAirlines';
            tableName = 'flights';
            % srcBucket = 's3://testpsp/unittestsrc';
            % resultBucket = 's3://testpsp/unittestresult';
            % srcBucket = 's3://testpsp/airline';
            resultBucket = 's3://testpsp/airlineresult';
            athena = aws.athena.AthenaClient();
            athena.Database = [dbName, '.', tableName];
            
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
                queryStr, resultBucket);
            testCase.verifyEqual(queryStatus, 'SUCCEEDED', ...
                'The query should be successful');
            
            athena.shutdown();
            
        end
    end
    
    % Helper methods
    methods
        function doAlternativeInitialize(testCase, ath)
            reg = getenv('REGION');
            awsKeyId = getenv('AWSACCESSKEYID');
            awsSecretKey = getenv('SECRETACCESSKEY');
            
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

