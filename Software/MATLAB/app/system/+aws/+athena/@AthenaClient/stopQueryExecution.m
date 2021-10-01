function [stat, statMsg] = stopQueryExecution(obj, queryId)
    % stopQueryExecution
    % 
    % This method will stop a running query execution.
    %
    % For example:
    %   ath = aws.athena.AthenaClient();
    %   ath.Database = 'sampledatabase';
    %   ath.initialize();
    %   execId = ath.submitQuery('SELECT * from sampledatabase.sampletable', 's3://sampleresults');
    %   status = ath.stopQueryExecution(execId)
    %
    
    % Copyright 2018-2019 The MathWorks, Inc.
    import software.amazon.awssdk.services.athena.model.StopQueryExecutionRequest
    import software.amazon.awssdk.services.athena.model.StopQueryExecutionResponse
    
    ath = obj.Handle;
    
    gqer = StopQueryExecutionRequest.builder() ...
        .queryExecutionId(queryId) ...
        .build();
    
    resp = ath.stopQueryExecution(gqer);
    httpResp = resp.sdkHttpResponse();
    stat = httpResp.isSuccessful;
    if nargout > 1
        statMsg = httpResp.statusText();
    end
    
end %function