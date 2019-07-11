%% Example for simlpe AWS Athena execution and datastore retrieval
% This example assumes a working AWS account and an S3 storage.
%   It will execute a simple SQL statement on some data (located on S3) and
%   write the results to another S3 bucket. An Athena database  must also configured.
%   .
%
%   This example uses the data in the file <a href="matlab:which('airlinesmall.csv')">airlinesmall.csv</a>
%
%   To prepare for the demo, copy this data to a bucket on S3, and then
%   create an Athena database from this data. In this example, it's called 
%   MyAirlines.flights
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

%% Setup values 
% These two values should correspond to the database and result bucket
% in use.
dbName = 'MyAirlines.flights';
resultBucket = 's3://testpsp/airlineresult';
distLimit = 1000;

%% Connect to database
ath = aws.athena.AthenaClient();
ath.Database = dbName;
ath.initialize

queryFar = sprintf('SELECT UniqueCarrier, distance FROM %s WHERE distance > %d;', ...
    dbName, distLimit);
resultIDFar = ath.submitQuery(queryFar, resultBucket);

counter = 10;
status = char(ath.getStatusOfQuery(resultIDFar));
while ~strcmp('SUCCEEDED', status) && counter >= 0
    status = char(ath.getStatusOfQuery(resultIDFar));
    fprintf('... waiting for %s to finish [%s] -- %d\n', char(resultIDFar), status, counter);
    pause(1);
    counter = counter - 1;    
end

if ~strcmp('SUCCEEDED', status)
    error('The Athena SQL query didn''t succeed.\n');
end


resFile = sprintf('%s/%s.csv', resultBucket, char(resultIDFar));
ds = datastore(resFile);
ds.NumHeaderLines = 1;
farResult = ds.readall();

