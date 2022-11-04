function tbl = readAnalyticalSampleFiles(folder,expression)
% readAnalyticalSampleFiles  Reads and merges analytical sample files
%   READANALYTICALSAMPLEFILES finds all analytical sample files in a folder,
%     reads them and concatenates them vertically.
%
%   Syntax
%     tbl = READANALYTICALSAMPLEFILES(folder,expression)
%
%   Description
%     tbl = READANALYTICALSAMPLEFILES(folder,expression) finds all files in
%       directory folder that match the regular expression
%       '<expression>_analyticalSamples.*\.xlsx$' reads and concatenates them.
%
%   Example(s)
%     tbl = READANALYTICALSAMPLEFILES('~/data','AL570_BIGO') will match
%     '~/data/AL570_BIGO_analyticalSamples.xlsx' and also
%     '~/data/AL570_BIGO_analyticalSamples_DIC.xlsx', etc.
%
%
%   Input Arguments
%     folder - path to folder
%       char row vector
%         The absolute or relative path to the folder in which to look for
%         analytcial sample files.
%
%     expression - regular expression to filter files
%       char row vector
%         A valid regular expression to filter the files found in folder with.
%         Files are filtered with the regular expression
%         '<expression>_analyticalSamples.*\.xlsx$'.
%
%
%   Output Arguments
%     tbl - output table
%       table
%         The output table holding the concatenated data of all matching files.
%
%
%   Name-Value Pair Arguments
%
%
%   See also UTILITYKIT.UTILITES.TABLE.READTABLEFILE, REGEXP
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import DebuggerKit.Debugger.printDebugMessage
    import UtilityKit.Utilities.table.readTableFile
    
    expression  = [expression,'_analyticalSamples.*\.xlsx$'];
    fileList    = struct2table(dir(folder));
    fileMask    = ~cellfun(@isempty,regexp(fileList{:,'name'},expression));
    fileList    = fileList(fileMask,:);
    nFiles      = sum(fileMask);
    
    if nFiles == 0
        expression = strrep(expression,'\','\\'); % Replace escape character to be aple to work with cprintf
        printDebugMessage('Dingi:GearKit:gearDeployment:readAnalyticalSampleFiles:ColumnMismatch','Warning',...
            'No analytical samples file matching expression ''%s'' found in folder ''%s''.',expression,folder)
    end
    
    tbl = table();
    for ff = 1:nFiles
        % Read new data
        try
            filename    = [fileList{ff,'folder'}{:},filesep,fileList{ff,'name'}{:}];
            tblNew      = readTableFile(filename);
        catch ME
            switch ME.identifier
                case 'Utilities:table:readTableFile:InvalidFile'
                    printDebugMessage('Dingi:GearKit:gearDeployment:readAnalyticalSampleFiles:ColumnMismatch','Error',...
                        'No analytical samples file with name ''%s'' found.',filename)
                otherwise
                    rethrow(ME)
            end
        end
        
        % Append new data
        try
            tbl = cat(1,tbl,tblNew);
        catch ME
            switch ME.identifier
                case 'MATLAB:table:vertcat:SizeMismatch'
                    printDebugMessage('Dingi:GearKit:gearDeployment:readAnalyticalSampleFiles:ColumnMismatch','Error',...
                        'File ''%s'' has a mismatching number of columns for the analytical samples table. It is not appended.',filename)
                case 'MATLAB:table:vertcat:UnequalVarNames'
                    printDebugMessage('Dingi:GearKit:gearDeployment:readAnalyticalSampleFiles:ColumnMismatch','Error',...
                        'File ''%s'' has the wrong column names for the analytical samples table. It is not appended.',filename)
                otherwise
                    rethrow(ME)
            end
        end
    end
end
