function execId = submitQuery(obj, queryString, resultBucket, varargin)
    % SUBMITQUERY Submit a query to Athena
    % Submit a query to Athena providing the SQL query string and the output
    % bucket to write the results.
    %
    % For example:
    %   ath = aws.athena.AthenaClient();
    %   ath.Database = 'sampledatabase';
    %   ath.initialize();
    %   ath.submitQuery('SELECT * from sampledatabase.sampletable', 's3://sampleresults');
    %
    % When the query has finished, the results may be used, e.g. through a datastore.
    %   ds = datastore('s3://sampleresults');
    
    % Copyright 2018-2019 The MathWorks, Inc.
    
    import software.amazon.awssdk.services.athena.model.QueryExecutionContext
    import software.amazon.awssdk.services.athena.model.ResultConfiguration
    import software.amazon.awssdk.services.athena.model.StartQueryExecutionRequest
    import software.amazon.awssdk.services.athena.model.StartQueryExecutionResponse
    
    qec = ...
        QueryExecutionContext.builder() ...
        .database(obj.Database) ...
        .build();
    
    resConf = ResultConfiguration.builder() ...
        .outputLocation(resultBucket) ...
        .build();
    
    ath = obj.Handle;
    
    sqer = StartQueryExecutionRequest.builder() ...
        .queryString(queryString) ...
        .queryExecutionContext(qec) ...
        .resultConfiguration(resConf) ...
        .build();
    
    queryExecutionResponse = ath.startQueryExecution(sqer);
    

    execId = queryExecutionResponse.queryExecutionId();
    
        
end 

