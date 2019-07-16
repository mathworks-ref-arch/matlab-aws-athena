
#  MATLAB Interface *for AWS Athena*
MATLAB® Interface for Amazon Web Services Athena™ Service.
Amazon Athena is an interactive query service that makes it easy to analyze data in Amazon S3 using standard SQL. Athena is serverless, so there is no infrastructure to manage, and you pay only for the queries that you run. This package provides a basic interface to a subset of Athena features
from within MATLAB.

## Requirements
### MathWorks products
* Requires MATLAB release R2017b or later.
* AWS Common utilities found at https://github.com/mathworks-ref-arch/matlab-aws-common

### 3rd party products
* Amazon Web Services account   

To build a required JAR file:   
* [Maven](https://maven.apache.org/)
* JDK 8+

## Getting Started
Please refer to the [Documentation](Documentation/README.md) to get started.
The [Installation Instructions](Documentation/Installation.md) and [Basic Usage](Documentation/BasicUsage.md) documents provide detailed instructions on setting up and using the interface. The easiest way to
fetch this repository and all required dependencies is to clone the top-level repository using:

```bash
git clone --recursive https://github.com/mathworks-ref-arch/mathworks-aws-support.git
```

### Build the AWS SDK for Java components
The MATLAB code uses the AWS SDK for Java and can be built using:
```bash
cd matlab-aws-athena/Software/Java
mvn clean package
```

Once built, use the ```matlab-aws-athena/Software/MATLAB/startup.m``` function to initialize the interface which will use the AWS Credentials Provider Chain to authenticate. Please see the [relevant documentation](Documentation/Authentication.md) on how to specify the credentials.

### Using the interface


```matlab
% Create some data needed in the examples
dbName = 'MyAirlines.airlines';
resultBucket = 's3://testing/airlineresult';
distLimit = 1000;

% Create the client object and authenticate using 
%   the AWS Default Provider Chain
ath = aws.athena.AthenaClient();
ath.Database = dbName;
ath.initialize


% Create a SQL statement and execute it (asynchronously)
queryFar = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
    dbName, distLimit);
resultIDFar = ath.submitQuery(queryFar, resultBucket);

% Check the status, and make sure it says 'SUCCEEDED'
status = char(ath.getStatusOfQuery(resultIDFar));

% At this point, we can read the results by using a MATLAB datastore
resFile = sprintf('%s/%s.csv', resultBucket, char(resultIDFar));
ds = datastore(resFile);
ds.NumHeaderLines = 1;
farResult = ds.readall();

```

## Supported Products:
1. [MATLAB](https://www.mathworks.com/products/matlab.html) (R2017b or later)
2. [MATLAB Compiler™](https://www.mathworks.com/products/compiler.html) and [MATLAB Compiler SDK™](https://www.mathworks.com/products/matlab-compiler-sdk.html) (R2017b or later)
3. [MATLAB Production Server™](https://www.mathworks.com/products/matlab-production-server.html) (R2017b or later)
4. [MATLAB Parallel Server™](https://www.mathworks.com/products/distriben.html) (R2017b or later)

## License
The license for the MATLAB Interface *for AWS Athena* is available in the [LICENSE.TXT](LICENSE.TXT) file in this GitHub repository. This package uses certain third-party content which is licensed under separate license agreements. See the [pom.xml](Software/Java/pom.xml) file for third-party software downloaded at build time.

## Enhancement Request
Provide suggestions for additional features or capabilities using the following link:   
https://www.mathworks.com/products/reference-architectures/request-new-reference-architectures.html

## Support
Email: `mwlab@mathworks.com`    

[//]: #  (Copyright 2019 The MathWorks, Inc.)
