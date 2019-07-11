# MATLAB Interface *for AWS Athena* API documentation


## AWS Athena Interface Objects and Methods:
* @AthenaClient



------

## @AthenaClient

### @AthenaClient/AthenaClient.m
```notalanguage
  CLIENT Object to represent an AWS Athena client
  The client is used to carry out operations with the Athena service
 
  Example:
     % Create client
     ath = aws.athena.AthenaClient;
     % Set the database
     ath.Database = 'Airlines';
     % Initialize the client
     ath.initialize();
     % Use the client to carry out queries on Athena
     query = SELECT UniqueCarrier, distance FROM Airlines WHERE distance > 500;';
     queryId = ath.submitQuery(query, 's3://results/airlinesresults');
     % Shutdown the client when no longer needed
     ath.shutdown();

    Reference page in Doc Center
       doc aws.athena.AthenaClient

```
### @AthenaClient/getStatusOfQuery.m
```notalanguage
  getStatusOfQuery
  A call to execute a query will return almost immediately, although
  the query can keep running for long. This method retrieves the status
  of the curent query with the corresponding ID. 
 
  For example:
    ath = aws.athena.AthenaClient();
    ath.Database = 'sampledatabase';
    ath.initialize();
    execId = ath.submitQuery('SELECT * from sampledatabase.sampletable', 's3://sampleresults');
    status = ath.getStatusOfQuery(execId)
```
### @AthenaClient/initialize.m
```notalanguage
  INITIALIZE Method to initialize the client handle.
 
  This method is used for initializing the AhtenaClient object. 
  When used without arguments, it will use the default AWS Credentials
  Provider and the default Region, by using the corrsponding chains.
 
    ath.initialize()
  
  To specify details, use named arguments.
 
   To specify a region:
    ath.initialize('region', 'eu-central-1')
 
   To specify a credentialsprovider
    ath.initialize('credentialsprovider', ...
       aws.auth.CredentialProvider.getBasicCredentialProvider('myid', 'mykey'));
 
   The two can also be combined if necessary.
```
### @AthenaClient/shutdown.m
```notalanguage
  SHUTDOWN Method to shutdown a client and release resources
  This method should be called to cleanup a client which is no longer
  required.
 
  The shutdown function is automatically called when the AthenaClient
  object is deleted.
 
  Example:
     % Create client
     ath = aws.athena.AthenaClient;
     % Perform operations using the client then shutdown
     ath.shutdown();
```
### @AthenaClient/submitQuery.m
```notalanguage
  SUBMITQUERY Submit a query to Athena
  Submit a query to Athena providing the SQL query string and the output
  bucket to write the results.
 
  For example:
    ath = aws.athena.AthenaClient();
    ath.Database = 'sampledatabase';
    ath.initialize();
    ath.submitQuery('SELECT * from sampledatabase.sampletable', 's3://sampleresults');
 
  When the query has finished, the results may be used, e.g. through a datastore.
    ds = datastore('s3://sampleresults');
```

------
## AWS Athena Authorization Interface Objects and Methods:
* @CredentialProvider



------

## @CredentialProvider

### @CredentialProvider/CredentialProvider.m
```notalanguage
  CredentialProvider A helper class for creating different types of AWS
  Credential Providers.

    Reference page in Doc Center
       doc aws.auth.CredentialProvider

```

------


## AWS Common Objects and Methods:
* @ClientConfiguration
* @Object



------

## @ClientConfiguration

### @ClientConfiguration/ClientConfiguration.m
```notalanguage
  CLIENTCONFIGURATION creates a client network configuration object
  This class can be used to control client behavior such as:
   * Connect to the Internet through proxy
   * Change HTTP transport settings, such as connection timeout and request retries
   * Specify TCP socket buffer size hints
  (Only limited proxy related methods are currently available)
 
  Example:
    s3 = aws.s3.Client();
    s3.clientConfiguration.setProxyHost('proxyHost','myproxy.example.com');
    s3.clientConfiguration.setProxyPort(8080);
    s3.initialize();

    Reference page in Doc Center
       doc aws.ClientConfiguration

```
### @ClientConfiguration/setProxyHost.m
```notalanguage
  SETPROXYHOST Sets the optional proxy host the client will connect through.
  This is based on the setting in the MATLAB preferences panel. If the host
  is not set there on Windows then the Windows system preferences will be
  used. The proxy settings may vary based on the URL, thus a sample URL
  should be provided if a specific URL is not known https://s3.amazonaws.com
  is a useful default as it is likely to match the relevant proxy selection
  rules.
 
  Examples:
 
    To have the proxy host automatically set based on the MATLAB preferences
    panel using the default URL of 'https://s3.amazonaws.com:'
        clientConfig.setProxyHost();
 
    To have the proxy host automatically set based on the given URL:
        clientConfig.setProxyHost('autoURL','https://examplebucket.amazonaws.com');
 
    To force the value of the proxy host TO a given value, e.g. myproxy.example.com:
        clientConfig.setProxyHost('proxyHost','myproxy.example.com');
    Note this does not overwrite the value set in the preferences panel.
 
  The s3 client initialization call will invoke setProxyHost();
  to set preference based on the MATLAB preference if the proxyHost value is not
  an empty value.
```
### @ClientConfiguration/setProxyPassword.m
```notalanguage
  SETPROXYPASSWORD Sets the optional proxy password.
  This is based on the setting in the MATLAB preferences panel. If the
  preferences password is not set then on Windows the OS system preferences
  will be used.
 
  Examples:
 
    To set the password to a given value:
        clientConfig.setProxyPassword('2312sdsdes?$!%');
    Note this does not overwrite the value set in the preferences panel.
 
    To set the password automatically based on provided preferences:
        clientConfig.setProxyPassword();
 
  The s3 client initialization call will invoke setProxyPassword();
  to set preference based on the MATLAB preference if the proxyPassword value is
  not an empty value.
 
  Note, it is bad practice to store credentials in code, ideally this value
  should be read from a permission controlled file or other secure source
  as required.
```
### @ClientConfiguration/setProxyPort.m
```notalanguage
  SETPROXYPORT Sets the optional proxy port the client will connect through.
  This is normally based on the setting in the MATLAB preferences panel. If the
  port is not set there on Windows then the Windows system preferences will be
  used. The proxy settings may vary based on the URL, thus a sample URL
  should be provided if a specific URL is not known https://s3.amazonaws.com
  is a useful default as it is likely to match the relevant proxy selection
  rules.
 
  Examples:
 
    To have the port automatically set based on the default URL of
    https://s3.amazonaws.com:
        clientConfig.setProxyPort();
 
    To have the port automatically set based on the given URL:
        clientConfig.setProxyPort('https://examplebucket.amazonaws.com');
 
    To force the value of the port to a given value, e.g. 8080:
        clientConfig.setProxyPort(8080);
    Note this does not alter the value held set in the preferences panel.
 
  The s3 client initialization call will invoke setProxyPort();
  to set preference based on the MATLAB preference if the proxyPort value is not
  an empty value.
```
### @ClientConfiguration/setProxyUsername.m
```notalanguage
  SETPROXYUSERNAME Sets the optional proxy username.
  This is based on the setting in the MATLAB preferences panel. If the
  username is not set there on Windows then the Windows system preferences
  will be used.
 
  Examples:
 
     To set the username to a given value:
         clientConfig.setProxyUsername('JoeProxyUser');
     Note this does not overwrite the value set in the preferences panel.
 
     To set the password automatically based on provided preferences:
         clientConfig.setProxyUsername();
 
  The s3 client initialization call will invoke setProxyUsername();
  to set preference based on the MATLAB preference if the proxyUsername value is
  not an empty value.
 
  Note it is bad practice to store credentials in code, ideally this value
  should be read from a permission controlled file or other secure source
  as required.
```

------


## @Object

### @Object/Object.m
```notalanguage
  OBJECT Root object for all the AWS SDK objects

    Reference page in Doc Center
       doc aws.Object

```

------

## AWS Common Related Functions:
### functions/Logger.m
```notalanguage
  Logger - Object definition for Logger
  ---------------------------------------------------------------------
  Abstract: A logger object to encapsulate logging and debugging
            messages for a MATLAB application.
 
  Syntax:
            logObj = Logger.getLogger();
 
  Logger Properties:
 
      LogFileLevel - The level of log messages that will be saved to the
      log file
 
      DisplayLevel - The level of log messages that will be displayed
      in the command window
 
      LogFile - The file name or path to the log file. If empty,
      nothing will be logged to file.
 
      Messages - Structure array containing log messages
 
  Logger Methods:
 
      clearMessages(obj) - Clears the log messages currently stored in
      the Logger object
 
      clearLogFile(obj) - Clears the log messages currently stored in
      the log file
 
      write(obj,Level,MessageText) - Writes a message to the log
 
  Examples:
      logObj = Logger.getLogger();
      write(logObj,'warning','My warning message')
 



```
### functions/aws.m
```notalanguage
  AWS, a wrapper to the AWS CLI utility
 
  The function assumes AWS CLI is installed and configured with authentication
  details. This wrapper allows use of the AWS CLI within the
  MATLAB environment.
 
  Examples:
     aws('s3api list-buckets')
 
  Alternatively:
     aws s3api list-buckets
 
  If no output is specified, the command will echo this to the MATLAB
  command window. If the output variable is provided it will convert the
  output to a MATLAB object.
 
    [status, output] = aws('s3api','list-buckets');
 
      output =
 
        struct with fields:
 
            Owner: [1x1 struct]
          Buckets: [15x1 struct]
 
  By default a struct is produced from the JSON format output.
  If the --output [text|table] flag is set a char vector is produced.
 



```
### functions/homedir.m
```notalanguage
  HOMEDIR Function to return the home directory
  This function will return the users home directory.



```
### functions/isEC2.m
```notalanguage
  ISEC2 returns true if running on AWS EC2 otherwise returns false



```
### functions/loadKeyPair.m
```notalanguage
  LOADKEYPAIR2CERT Reads public and private key files and returns a key pair
  The key pair returned is of type java.security.KeyPair
  Algorithms supported by the underlying java.security.KeyFactory library
  are: DiffieHellman, DSA & RSA.
  However S3 only supports RSA at this point.
  If only the public key is a available e.g. the private key belongs to
  somebody else then we can still create a keypair to encrypt data only
  they can decrypt. To do this we replace the private key file argument
  with 'null'.
 
  Example:
   myKeyPair = loadKeyPair('c:\Temp\mypublickey.key', 'c:\Temp\myprivatekey.key')
 
   encryptOnlyPair = loadKeyPair('c:\Temp\mypublickey.key')
 
 



```
### functions/saveKeyPair.m
```notalanguage
  SAVEKEYPAIR Writes a key pair to two files for the public and private keys
  The key pair should be of type java.security.KeyPair
 
  Example:
    saveKeyPair(myKeyPair, 'c:\Temp\mypublickey.key', 'c:\Temp\myprivatekey.key')
 



```
### functions/unlimitedCryptography.m
```notalanguage
  UNLIMITEDCRYPTOGRAPHY Returns true if unlimited cryptography is installed
  Otherwise false is returned.
  Tests using the AES algorithm for greater than 128 bits if true then this
  indicates that the policy files have been changed to enabled unlimited
  strength cryptography.



```
### functions/writeSTSCredentialsFile.m
```notalanguage
  WRITESTSCREDENTIALSFILE write an STS based credentials file
 
  Write an STS based credential file
 
    tokenCode is the 2 factor authentication code of choice e.g. from Google
    authenticator. Note the command must be issued quickly as this value will
    expire in a number of seconds
 
    serialNumber is the AWS 'arn value' e.g. arn:aws:iam::741<REDACTED>02:mfa/joe.blog
    this can be obtained from the AWS IAM portal interface
 
    region is the AWS region of choice e.g. us-west-1
 
  The following AWS command line interface (CLI) command will return STS
  credentials in json format as follows, Note the required multi-factor (mfa)
  auth version of the arn:
 
  aws sts get-session-token --token-code 631446 --serial-number arn:aws:iam::741<REDACTED>02:mfa/joe.blog
 
  {
      "Credentials": {
          "SecretAccessKey": "J9Y<REDACTED>BaJXEv",
          "SessionToken": "FQoDYX<REDACTED>KL7kw88F",
          "Expiration": "2017-10-26T08:21:18Z",
          "AccessKeyId": "AS<REDACTED>UYA"
      }
  }
 
  This needs to be rewritten differently to match the expected format
  below:
 
  {
      "aws_access_key_id": "AS<REDACTED>UYA",
      "secret_access_key" : "J9Y<REDACTED>BaJXEv",
      "region" : "us-west-1",
      "session_token" : "FQoDYX<REDACTED>KL7kw88F"
  }



```



------------    

[//]: # (Copyright 2019 The MathWorks, Inc.)
