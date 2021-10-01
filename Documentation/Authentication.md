# Authentication

To access the AWS™ service it is necessary to authenticate with AWS. This can be accomplished in two ways:
1. Using the default AWS Credential Provider Chain, to iterate through the default AWS authentication methods. This is the default authentication mechanism.
2. By explicitly instantiating a AWS CredentialsProvider.

Particularly if using other AWS tools or services the first methods can be more convenient as one can have a common authentication process.

## Credential Provider Chain
When a client is initialized, by default, it attempts to find AWS credentials by using the default credential provider chain as implemented by the AWS SDK. This looks for credentials in this order:

1. Environment variables: *AWS_ACCESS_KEY_ID*, *AWS_DEFAULT_REGION* and *AWS_SECRET_ACCESS_KEY*.
2. Java system properties: *aws.accessKeyId* and *aws.secretKey*.
3. The default credential profiles file, typically store in *~/.aws/credentials* (Linux) or *c:\\Users\\username\\.aws\\* (Windows) and shared by many of the AWS SDKs and by the AWS CLI. A credentials file can be created by using the aws configure command provided by the AWS CLI, or by editing the file with a text editor. For information about the credentials file format, see AWS Credentials File Format: <https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html#credentials-file-format>.
4. Amazon™ ECS™ container credentials are loaded from the Amazon ECS if the environment variable *AWS_CONTAINER_CREDENTIALS_RELATIVE_URI* is set.
5. Instance profile credentials as used on EC2™ instances, and delivered through the Amazon EC2 metadata service.

For more information on the credential provider chain see: <https://docs.aws.amazon.com/sdk-for-java/v2/developer-guide/credentials.html>


### Using Environment variables
The environment variables *AWS_ACCESS_KEY_ID*, *AWS_DEFAULT_REGION* and *AWS_SECRET_ACCESS_KEY* must be set in the process context used to start MATLAB®, that is the must be set before MATLAB is started and cannot be set using the MATLAB *setenv* command as they must be set in the context of the MATLAB JVM. One can verify if they have been set correctly using the following command rather than the MATLAB *getenv* command:
```
java.lang.System.getenv('AWS_DEFAULT_REGION')

ans =

us-west-1
```
If they have not been set, a Java exception is raised from the provider chain.

### Using IAM Role based access
When running on EC2 an EC2 instance may *not* have an IAM Role associated with it to allow access to a given resource. If the EC2 instance IAM Role is not there or is improperly configured, an error will occur.

To attach IAM Role to existing EC2 instance, please see: <https://aws.amazon.com/blogs/security/easily-replace-or-attach-an-iam-role-to-an-existing-ec2-instance-by-using-the-ec2-console/>


## Instantiating a `CredentialProvider`
The AWS SDK provides a series of different `CredentialProvider`s, and this API implements a few of them.

Use the utility class to instantiate a `CredentialProvider`, and then pass this argument
to the initialize function.

```matlab
    credProvider = aws.auth.CredentialProvider.getSessionCredentialProvider(...
        'A<REDACTED>Q', ... % id
        'Z<REDACTED>4', ... % key
        'F<REDACTED>F');    % token

    ath = aws.athena.AthenaClient(); 
    ath.initialize('credentialsprovider', credProvider);
```

If you need to add a region, add this as a text argument:
```matlab
    ath.initialize('region', 'eu-central-1', ...
        'credentialsprovider', credProvider)
```
If none of the arguments are used, the methods will try to deduce the correct region and credentials provider with the underlying libraries.

The methods currently provided by this class are

* `getBasicCredentialProvider`
* `getProfileCredentialProvider`
* `getInstanceProfileCredentialProvider`
* `getSessionCredentialProvider`
* `getJsonFileCredentialProvider`

and they all return an object that implements the Java interface
`software.amazon.awssdk.auth.credentials.AwsCredentialsProvider`
This means, that a user can easily instantiate and provide another
object if needed.




[//]: #  (Copyright 2019 The MathWorks, Inc.)
