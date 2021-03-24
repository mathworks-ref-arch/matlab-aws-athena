classdef TestAuthorization < matlab.unittest.TestCase
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
        function testDefaultCredentialsProvider(testCase)
            % Create the object
            [ath, queryStr, resultBucket] = getDefaultClient(testCase);
            
            % Pick content provider here
            
            if testCase.isOnGitlab
                doAlternativeInitialize(testCase, ath)
            else
                ath.initialize();
            end
            
            
            resultID = ath.submitQuery(queryStr, resultBucket);
            
        end
        
        % Comment out this test since not adding real tokens to repo
        %         function testBasicCredentialsProvider(testCase)
        %             % Create the object
        %             [ath, queryStr, resultBucket] = getDefaultClient(testCase);
        %
        %             % Pick content provider here
        %             cp = aws.auth.CredentialProvider.getBasicCredentialProvider('A<RETRACTED>6', '2<RETRACTED>H');
        %
        %             ath.initialize('credentialsprovider', cp);
        %
        %             try
        %                 resultID = ath.submitQuery(queryStr, resultBucket);
        %             catch ex
        %                 testCase.assertTrue(false, 'This authentication method failed');
        %             end
        %
        %         end
        
        % Comment out this test since not adding real tokens to repo
        %         function testSessionCredentialsProvider(testCase)
        %             % Create the object
        %             [ath, queryStr, resultBucket] = getDefaultClient(testCase);
        %
        %             % Pick content provider here
        %             cp = aws.auth.CredentialProvider.getSessionCredentialProvider('A<RETRACTED>6', '2<RETRACTED>H', '2<RETRACTED>H');
        %
        %             ath.initialize('credentialsprovider', cp);
        %
        %             try
        %                 resultID = ath.submitQuery(queryStr, resultBucket);
        %             catch ex
        %                 testCase.assertTrue(false, 'This authentication method failed');
        %             end
        %
        %         end
        
        function testBasicCredentialsProviderNegative(testCase)
            % Create the object
            [ath, queryStr, resultBucket] = getDefaultClient(testCase);
            
            % Pick content provider here
            cp = aws.auth.CredentialProvider.getBasicCredentialProvider('id-not-valid', 'key-not-valid-either');
            
            testCase.assertTrue(isa(cp, 'software.amazon.awssdk.auth.credentials.StaticCredentialsProvider'), 'Wrong class');
            testCase.assertTrue(isjava(cp), 'It should be a Java class');
            args = {'credentialsprovider', cp};
            if testCase.isOnGitlab
                args = [args, 'region', getenv('REGION')];
            end
            ath.initialize(args{:});
            
            try
                resultID = ath.submitQuery(queryStr, resultBucket);
                testCase.assertTrue(false, 'This authentication method should fail, but it didn''t');
            catch ex
                % All well, we failed.
            end
            
        end
        
        
        
        function testSessionCredentialsProviderNegative(testCase)
            % Create the object
            [ath, queryStr, resultBucket] = getDefaultClient(testCase);
            
            % Pick content provider here
            cp = aws.auth.CredentialProvider.getSessionCredentialProvider('id-not-valid', 'key-not-valid', 'token-not-valid');
            testCase.assertTrue(isa(cp, 'software.amazon.awssdk.auth.credentials.StaticCredentialsProvider'), 'Wrong class');
            testCase.assertTrue(isjava(cp), 'It should be a Java class');
            
            args = {'credentialsprovider', cp};
            if testCase.isOnGitlab
                args = [args, 'region', getenv('REGION')];
            end
            ath.initialize(args{:});
            
            try
                resultID = ath.submitQuery(queryStr, resultBucket); %#ok<NASGU>
                testCase.assertTrue(false, 'This authentication method should fail, but it didn''t');
            catch ex %#ok<NASGU>
                % All well, we failed.
            end
            
        end
        
        
        function testProfileCredentialsProvider(testCase)
            % Create the object
            [ath, queryStr, resultBucket] = getDefaultClient(testCase);
            
            
            if testCase.isOnGitlab
                doAlternativeInitialize(testCase, ath)
            else
                
                % Pick content provider here
                %  This temporary credeeeeentials provider must be created
                %  before the test is run.
                cp = aws.auth.CredentialProvider.getProfileCredentialProvider('win');
                
                ath.initialize('credentialsprovider', cp);
            end
            
            try
                resultID = ath.submitQuery(queryStr, resultBucket);
            catch ex
                testCase.assertTrue(false, 'This authentication method failed.\n%s\n', ex.message);
            end
            
        end
        
        function testProfileCredentialsProviderNegative(testCase)
            % Create the object
            [ath, queryStr, resultBucket] = getDefaultClient(testCase);
            
            % Pick content provider here
            %  This temporary credeeeeentials provider must be created
            %  before the test is run.
            cp = aws.auth.CredentialProvider.getProfileCredentialProvider('gobbledygook');
            
            args = {'credentialsprovider', cp};
            if testCase.isOnGitlab
                args = [args, 'region', getenv('REGION')];
            end
            ath.initialize(args{:});
            
            
            try
                resultID = ath.submitQuery(queryStr, resultBucket);
                testCase.assertTrue(false, 'This authentication method should fail, but it didn''t');
            catch ex
                % All well, we failed.
            end
            
        end
        
        function testJsonFileCredentialsProvider(testCase)
            % Create the object
            [ath, queryStr, resultBucket] = getDefaultClient(testCase);
            
            jsonFile = which('credentials.json');
            
            testCase.assertNotEmpty(jsonFile, 'There must be a "credentials.json" file present for testing');
            
            
            [cp, region] = aws.auth.CredentialProvider.getJsonFileCredentialProvider(jsonFile);
            
            args = {'credentialsprovider', cp};
            if ~isempty(region)
                args = [args, 'region', region];
            end
            ath.initialize(args{:});
            
            
            try
                resultID = ath.submitQuery(queryStr, resultBucket);
            catch ex
                testCase.assertTrue(false, 'This authentication method failed.\n%s\n', ex.message);
            end
            
        end
        
    end
    
    methods
        function [ath, queryStr, resultBucket] = getDefaultClient(~)
            dbName = 'MyAirlines.airlines';
            resultBucket = 's3://testpsp/airlineresult';
            distLimit = 1000;
            
            %% Connect to database
            ath = aws.athena.AthenaClient();
            ath.Database = dbName;
            
            queryStr = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
                dbName, distLimit);
            
        end
        
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

