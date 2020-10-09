function writeTableAndHeader(T,filename,varargin)
%writeTableAndHeader writes table T as an Excel-spreadsheet to the file
%filename and adds the column name, description & units as header lines.
%
%   Syntax:
%       writeTableAndHeader(T,filename)
%       writeTableAndHeader(__,Name,Value)
%
%
%   Input Arguments:
%       T - Input data
%           table
%
%           Input data, specified as a table.
%
%       filename - File name
%           table
%
%           File name, specified as a character vector. To write to a
%           specific folder, specify the full path name. Otherwise,
%           writeTableAndHeader writes to a file in the current folder.
%           One of the following file extension is required:
%               - .xls, .xlsx       (Excel spreadsheet)
%
%           If filename does not exist, then writetable creates the file.
%           If filename is the name of an existing text file, then
%           writetable overwrites the file.
%           If filename is the name of an existing spreadsheet file, then
%           writeTableAndHeader writes a table to the specified location,
%           but does not overwrite any values outside that range.
%
%
%   Output Arguments:
%
%
%   Name-Value Pair Arguments:
%       'WriteColumnNames' - indicator for writing variable names to column
%           heading
%           true (default) | false
%
%           Indicator for writing variable names to the column heading,
%           specified as the comma-separated pair consisting of
%           'WriteColumnNames' and either true or false.
%
%       'WriteColumnDescriptions' - indicator for writing variable 
%           descriptions to the column heading
%           true (default) | false
%
%           Indicator for writing variable descriptions to the column
%           heading, specified as the comma-separated pair consisting of
%           'WriteColumnDescriptions' and either true or false.
%
%       'WriteColumnUnits' - indicator for writing variable units to the
%           column heading
%           true (default) | false
%
%           Indicator for writing variable units to the column heading,
%           specified as the comma-separated pair consisting of
%           'WriteColumnUnits' and either true or false.
%
%       'VerboseMode' - indicator for entering verbose mode
%           false (default) | true
%
%           Indicator for entering verbose mode, specified as the
%           comma-separated pair consisting of 'VerboseMode' and either
%           true or false.
%           In verbose mode, status messages are output to the command
%           window.
%
%
%   Version History:
%       - 1.00  22.10.2018  initial version
%
%   Copyright 2018 David Clemens
%
%   see also writetable
%
    
%% PARSE INPUT
p                               = inputParser;
% define defaults
defaultWriteColumnNames         = true;
defaultWriteColumnDescriptions 	= true;
defaultWriteColumnUnits         = true;
defaultVerboseMode              = false;
% check functions
checkTable                      = @(x) istable(x);
checkFilename                   = @(x) ischar(x) && logical(regexp(x,'.*\.xlsx?'));
checkWriteColumnNames           = @(x) islogical(x);
checkWriteColumnDescriptions 	= @(x) islogical(x);
checkWriteColumnUnits           = @(x) islogical(x);
checkVerboseMode                = @(x) islogical(x);
% define inputs
addRequired(p,  'T',                                                        checkTable);
addRequired(p,  'filename',                                                 checkFilename);
addParameter(p,	'WriteColumnNames',         defaultWriteColumnNames,        checkWriteColumnNames);
addParameter(p,	'WriteColumnDescriptions',	defaultWriteColumnDescriptions,	checkWriteColumnDescriptions);
addParameter(p,	'WriteColumnUnits',         defaultWriteColumnUnits,      	checkWriteColumnUnits);
addParameter(p,	'VerboseMode',              defaultVerboseMode,             checkVerboseMode);
% parse inputs
parse(p,T,filename,varargin{:});
% extract inputs
T                       = p.Results.T;
filename            	= p.Results.filename;
WriteColumnNames     	= p.Results.WriteColumnNames;
WriteColumnDescriptions	= p.Results.WriteColumnDescriptions;
WriteColumnUnits       	= p.Results.WriteColumnUnits;
VerboseMode             = p.Results.VerboseMode;

%% FUNCTION
% extract requested header information
THeader = cell(0,size(T,2)); % initialize
if WriteColumnNames
    THeader     = [THeader;cellstr(T.Properties.VariableNames)];
    if VerboseMode
        fprintf('added column names...\n')
    end
end
if WriteColumnDescriptions
    THeader     = [THeader;cellstr(T.Properties.VariableDescriptions)];
    if VerboseMode
        fprintf('added column descriptions...\n')
    end
end
if WriteColumnUnits
    THeader     = [THeader;cellstr(T.Properties.VariableUnits)];
    if VerboseMode
        fprintf('added column units...\n')
    end
end
% append header information
TCell   = [THeader;table2cell(T)];

if VerboseMode
    fprintf('writing to file...\n')
end
% convert back to table
TOut    = cell2table(TCell,...
         	'VariableNames',    T.Properties.VariableNames);
% write to file
writetable(TOut,filename,...
    'WriteVariableNames',       false)

if VerboseMode
    fprintf('done.\n')
end

end