function dbt = fmtToDBType(fmt)
    % fmtToDBType A helper function to used for preparing the examples
    
    % Copyright 2018-2019 The MathWorks, Inc.

    switch fmt
        case '%f'
            dbt = 'double';
        case '%q'
            dbt = 'string';
        otherwise
            error('Unknown format: "%s"\n', fmt);
    end
    
end