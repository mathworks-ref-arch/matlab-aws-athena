function shutdown(obj)
    % SHUTDOWN Method to shutdown a client and release resources
    % This method should be called to cleanup a client which is no longer
    % required.
    %
    % The shutdown function is automatically called when the AthenaClient
    % object is deleted.
    %
    % Example:
    %    % Create client
    %    ath = aws.athena.AthenaClient;
    %    % Perform operations using the client then shutdown
    %    ath.shutdown();
    
    % Copyright 2018-2019 The MathWorks, Inc.

    if ~isempty(obj.Handle)
        obj.Handle.close();
        obj.Handle = [];
    end
end
