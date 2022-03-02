classdef TestAuthorization < matlab.unittest.TestCase
    % TESTCLIENT Unit Test for the Amazon Athena Client
    %
    % The test suite exercises the basic operations on the Athena Client.
    
    % Copyright 2018-2021 The MathWorks, Inc.
    
    
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
        function testTearDown(testCase) %#ok<MANU>
            
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
            
            resultID = ath.submitQuery(queryStr, resultBucket); %#ok<NASGU>
            
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
                args = [args, 'region', getenv('AWS_DEFAULT_REGION')];
            end
            ath.initialize(args{:});
            
            try
                resultID = ath.submitQuery(queryStr, resultBucket); %#ok<NASGU>
                testCase.assertTrue(false, 'This authentication method should fail, but it didn''t');
            catch ex %#ok<NASGU>
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
                args = [args, 'region', getenv('AWS_DEFAULT_REGION')];
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
                %  This temporary credentials provider must be created
                %  before the test is run.
                cp = aws.auth.CredentialProvider.getProfileCredentialProvider('default');
                
                ath.initialize('credentialsprovider', cp);
            end
            
            try
                resultID = ath.submitQuery(queryStr, resultBucket); %#ok<NASGU>
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
                args = [args, 'region', getenv('AWS_DEFAULT_REGION')];
            end
            ath.initialize(args{:});
            
            
            try
                resultID = ath.submitQuery(queryStr, resultBucket); %#ok<NASGU>
                testCase.assertTrue(false, 'This authentication method should fail, but it didn''t');
            catch ex %#ok<NASGU>
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
                resultID = ath.submitQuery(queryStr, resultBucket); %#ok<NASGU>
            catch ex
                testCase.assertTrue(false, ...
                    sprintf('This authentication method failed.\n%s\n', ex.message));
            end
            
        end
        
    end
    
    methods
        function [ath, queryStr, resultBucket] = getDefaultClient(~)
            dbName = 'myairlines.airlines';
            resultBucket = 's3://athenapspunittest/airlineresult';
            distLimit = 1000;
            
            %% Connect to database
            ath = aws.athena.AthenaClient();
            ath.Database = dbName;
            
            queryStr = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
                dbName, distLimit);
            
        end
        
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

