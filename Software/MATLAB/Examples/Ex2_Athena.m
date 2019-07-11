%% Example for simlpe AWS Athena execution and datastore retrieval
% This example assumes a working AWS account and an S3 storage.
%   It will execute a simple SQL statement on some data (located on S3) and
%   write the results to another S3 bucket. An Athena database  must also configured.
%
%   This example uses the data in the file <a href="matlab:which('airlinesmall.csv')">airlinesmall.csv</a>
%
%   To prepare for the demo, copy this data to a bucket on S3, and then
%   create an Athena database from this data. In this example, it's called 
%   MyAirlines.parquetflights
%   To facilitate creating this database, it can be helpful to look at the
%   information from the CSV file providing the data.
%
%         ds = datastore('airlinesmall.csv');
%         dbt=cellfun(@fmtToDBType, ds.TextscanFormats, 'Uni', 0);
%         names = ds.VariableNames;
%         both = [names;dbt];
%         str = sprintf('%s %s, ', both{:}); str(end-1:end)=[];
%         disp(str);
%
%   Use the above output for defining the types and columns of the Athena
%   database (Bulk add columns).
%
%   A bucket for storing results is also needed.

% Copyright 2018-2019 The MathWorks, Inc.

% These two values should correspond to the database and result bucket
% in use.
dbName = 'myairlines.parquetflights';
resultBucket = 's3://testpsp/parquetresults';

ath = aws.athena.AthenaClient();
ath.Database = dbName;
ath.initialize

N = 30;
limVec = floor(linspace(500,4500, N));
for k=1:N
    queryFar = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', dbName, limVec(k));
    resultIDFar = ath.submitQuery(queryFar, resultBucket);
    if rem(k,5)==1
        fprintf('#%03d: Started execution of %s\n', k, queryFar);
    else
        fprintf('.');
    end
end
fprintf('\n');


resFile = sprintf('%s/%s.csv', resultBucket, char(resultIDFar));
counter = 10;

status = char(ath.getStatusOfQuery(resultIDFar));
while ~strcmp('SUCCEEDED', status) && counter >= 0
    status = char(ath.getStatusOfQuery(resultIDFar));
    fprintf('... waiting for %s to finish [%s] -- %d\n', char(resultIDFar), status, counter);
    pause(1);
    counter = counter - 1;    
end

if ~strcmp('SUCCEEDED', status)
    error('Problems reading results from "%s"\n', resFile);
end

tic
ds = datastore(resFile);
ds.NumHeaderLines = 1;
farResult = ds.readall();
tReadDataStore = toc;
fprintf('Retrieved %d results in %.1f seconds from "%s"\n', height(farResult), tReadDataStore, resFile);
