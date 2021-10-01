# Basic Usage

This example assumes a working AWS account and an S3 storage.
It will execute a simple SQL statement on some data (located on S3) and
write the results to another S3 bucket.  An Athena database  must also configured.

This example uses the data from a MATLAB example file that can be found here (execute the following code in MATLAB):
```matlab
which airlinesmall.csv
```

## Database setup
To prepare for the demo, copy this data to a bucket on S3, and then
create an Athena database from this data. In this example, it's called 
`MyAirlines.airlines`.
Refer to the [AWS Athena](https://aws.amazon.com/athena/) pages for how to setup an Athena database.
To facilitate creating this database, it can be helpful to look at the
information from the CSV file providing the data.
```matlab
ds = datastore('airlinesmall.csv');
dbt=cellfun(@fmtToDBType, ds.TextscanFormats, 'Uni', 0);
names = ds.VariableNames;
both = [names;dbt];
disp(sprintf('%s %s, ', both{:}))
```
Use the above output for defining the types and columns of the Athena
database (*the `fmtToDBType`* file is present in the `Examples` directory).

Lastly, a bucketfor storing the results is needed, e.g.
```
s3://testingathena/outputs/
```
## Authentication
If *AWS CLI* is available on machine running MATLAB,  there will probably be a file like `~/.aws/credentials` on the machine.
If the credentials there are valid, it should be possible to start off without any issues. If not, there are other ways to
authenticate (see [Authentication](Authentication.md)).


## Running the code
### Setup variables
```matlab
dbName = 'MyAirlines.airlines';
resultBucket = 's3://testingathena/outputs/';
distLimit = 1000;
```

### Connect to the client
```matlab
ath = aws.athena.AthenaClient();
ath.Database = dbName;
ath.initialize
```

### Create and execute a query
```matlab
queryFar = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
 dbName, distLimit);
resultIDFar = ath.submitQuery(queryFar, resultBucket);
```
This function will return quickly, with a result string like *94079584-26b3-4caa-92cc-91fa94291bd4*, but the request may still be running.
The status of a running request can be checked like this:
```matlab
status = char(ath.getStatusOfQuery(resultIDFar));
```
which will show the current state of the query (**SUCCEEDED**, **RUNNING**, etc.).
When the query has succeeded, the resulting files can be found in S3, but these
files can also be retrieved directly from MATLAB. The result will have the name
```matlab
resFile = sprintf('%s/%s.csv', resultBucket, char(resultIDFar))
resFile =
    's3://testingathena/outputs/94079584-26b3-4caa-92cc-91fa94291bd4.csv'
```
This file can be read using a datastore. The datastore, however,
will rely on  having the AWS keys available in environment variables, so first
do something like this prior to starting MATLAB (example for Linux):
```bash
export AWS_DEFAULT_REGION=eu-central-1
export AWS_ACCESS_KEY_ID=A<RETRACTED>Z
export AWS_SECRET_ACCESS_KEY=B<RETRACTED>X
```

For Windows, change the variables in the Control Panel.

The MATLAB documentation for how to *"Work with remote data"* describes this in more detail.

After this,the data can be read from the datastore.
```matlab
ds = datastore(resFile);
ds.NumHeaderLines = 1;
farResult = ds.readall();
```
### Cancelling a query
If a query should be cancelled, it is done with the method `stopQueryExecution`.

```matlab
% Initialize
ath = aws.athena.AthenaClient();
ath.Database = dbName;
ath.initialize

% Submit a query
queryFar = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
 dbName, distLimit);
queryId = ath.submitQuery(queryFar, resultBucket);

% If realizing the query is wrong, or will run forever using up too much resources,
% it can be stopped easily.
[stopStatus, stopMsg] = ath.stopQueryExecution(queryId);

% If the status is queried at this point, it will in general be CANCELLED,
% unless the query had already finished (successfully or not)
queryStatus2 = ath.getStatusOfQuery(queryId)
queryStatus2 =
CANCELLED
```


## Athena limits
There are [limitations](https://docs.aws.amazon.com/athena/latest/ug/service-limits.html) to how many queries  can be run in Athena.
If the limit is exceeded,
the submitted query will fail with a message similar to this one.

    Problems executing Athena query:
    com.amazonaws.services.athena.model.AmazonAthenaException:
    Rate exceeded (Service: AmazonAthena; Status Code: 400;
    Error Code: ThrottlingException;
    Request ID: 5740d70a-e53d-4cb4-9c40-695cf31d828c)

This must be handled by the application.


## Proxy support
If use of a HTTP(S) proxy is required to access the Athena service it can be configured as follows:
```matlab
ath = aws.athena.AthenaClient();
ath.Database = dbName;

ath.ProxyConfiguration.host = 'myproxy.example.com';
ath.ProxyConfiguration.port = 3128;
            
ath.initialize
```

Note the proxy values must be configured prior to calling the `intialialize()` method. A username and password can optionally be provided for the proxy.

Alternatively if the proxy values are entered in the Web pane of MATLAB's preferences interface those values will be applied.
If both are provided those entered in the code take priority.


[//]: #  (Copyright 2019-2021 The MathWorks, Inc.)
