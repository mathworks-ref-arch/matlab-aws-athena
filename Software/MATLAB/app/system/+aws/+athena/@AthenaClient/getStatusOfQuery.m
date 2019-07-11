function [statMsg, stat] = getStatusOfQuery(obj, queryId)
    % getStatusOfQuery
    % A call to execute a query will return almost immediately, although
    % the query can keep running for long. This method retrieves the status
    % of the curent query with the corresponding ID. 
    %
    % For example:
    %   ath = aws.athena.AthenaClient();
    %   ath.Database = 'sampledatabase';
    %   ath.initialize();
    %   execId = ath.submitQuery('SELECT * from sampledatabase.sampletable', 's3://sampleresults');
    %   status = ath.getStatusOfQuery(execId)
    %
    
    % Copyright 2018-2019 The MathWorks, Inc.
    
    import software.amazon.awssdk.services.athena.model.GetQueryExecutionResponse
    import software.amazon.awssdk.services.athena.model.GetQueryExecutionRequest
    
    ath = obj.Handle;
    
    gqer = GetQueryExecutionRequest.builder() ...
        .queryExecutionId(queryId) ...
        .build();
    
    stat = ath.getQueryExecution(gqer);
    statMsg = stat.queryExecution.status.state();
    
    
end %function