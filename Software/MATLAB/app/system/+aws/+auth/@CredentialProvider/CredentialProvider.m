classdef CredentialProvider < handle
    % CredentialProvider A helper class for creating different types of AWS
    % Credential Providers.
    
    % Copyright 2018-2019 The MathWorks, Inc.
    
    properties
    end
    
    methods
    end
    methods (Static = true)
        function credProv = getProfileCredentialProvider(provName)
            % getProfileCredentialProvider Return credential provider from a named profile.
            import software.amazon.awssdk.auth.credentials.ProfileCredentialsProvider
            
            if nargin < 1 || isempty(provName)
                provName = 'default';
            end
            
            credProv = ProfileCredentialsProvider.create(provName);
        end
        
        
        function credProv = getInstanceProfileCredentialProvider()
            % Returns of a Credentials Provider for use on AWS machines
            import software.amazon.awssdk.auth.credentials.InstanceProfileCredentialsProvider
            
            credProv = InstanceProfileCredentialsProvider.create();
        end
        
        function credProv = getBasicCredentialProvider(awsID, awsKey)
            % Returns a AwsBasicCredentials for use with an ID and a Key
            import software.amazon.awssdk.auth.credentials.AwsBasicCredentials
            import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider
            
            credProv = StaticCredentialsProvider.create( AwsBasicCredentials.create(awsID, awsKey) );
        end
        
        function credProv = getSessionCredentialProvider(awsID, awsKey, awsSessionToken)
            % Returns a AwsSessionCredentials for use with ID, Key and SessionToken
            import software.amazon.awssdk.auth.credentials.AwsSessionCredentials
            import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider
            
            credProv = StaticCredentialsProvider.create( AwsSessionCredentials.create(awsID, awsKey, awsSessionToken) );
        end
        
        function [credProv, awsRegion] = getJsonFileCredentialProvider(jsonFile)
            % Returns a Credential Provider based on what is present in the JSON File
         
            % Create a client handle using basic static credentials
            credentials = jsondecode(fileread(jsonFile));
            % if there is no session token use static credentials otherwise use
            % STS credentials
            if ~isfield(credentials, 'session_token') || strcmp(strtrim(credentials.session_token),'')
                credProv = aws.auth.CredentialProvider.getBasicCredentialProvider(credentials.aws_access_key_id, credentials.secret_access_key);
            else
                credProv = aws.auth.CredentialProvider.getSessionCredentialProvider(credentials.aws_access_key_id, credentials.secret_access_key, credentials.session_token);
            end
            
            if isfield(credentials, 'region')
                awsRegion = credentials.region;
            else
                awsRegion = '';
            end
            
        end
        
        
    end
end