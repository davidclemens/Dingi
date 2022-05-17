function tbl = importTableFile(filename)
%importTableFile imports an Excel file with a defined 4-Line Header that
%   defines the column names (row 1), the column units (row 2), the column
%   description (row 3) and the column datatype (row 4).
%   The datatype can be any of the following:
%       - %d, %f    double-precision float
%       - %s        cellstring
%       - %cat      categorical array
%       - %D        datetime array
%       - %l        logical array
%
%   Syntax:
%       T = importTableFile(filename)
%
%
%   Input Arguments:
%       filename - full path to Excel file
%           character vector
%
%           Defines the full path to the Excel file.
%
%
%   Output Arguments:
%       T - output data table
%           table
%
%           Table of the Excel data.
%
%
%   Name-Value Pair Arguments:
%
%
%   Version History:
%       - 1.00  07.08.2018  initial version
%       - 1.10  20.09.2018  - new:  added documentation
%                           - new:  added version control
%                           - new:  added support for logical arrays
%
%   Copyright 2018 David Clemens
%

%% FUNCTION
% read excel file
[~,~,ext]  = fileparts(filename);
switch ext
    case {'.xlsx'}
        [~,~,rawWithHeader]       = xlsread(filename,'','','basic');
    otherwise
        error('Dingi:DataKit:importTableFile:unknownFiletype',...
            'The import of tables from files with file extension ''%s'' is not defined yet.',ext)
end


% make sure all header entries are cellstrings
rawHeader       = rawWithHeader(1:4,:);
rawHeader(~cellfun(@ischar,rawHeader))	= {''};

% extract header information
VarName         = rawHeader(1,:);     % extract variable name
VarUnit         = rawHeader(2,:);     % extract variable unit
VarDesc         = rawHeader(3,:);     % extract variable description
VarFormat       = rawHeader(4,:);     % extract variable format

% extract raw data
raw                 = rawWithHeader(5:end,:); % extract data
[nRows,nColumns]	= size(raw);

% remove empty data
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};

% definitions
validFormatSpec             = {'%d','%d8','%d16','%d32','%d64','%u','%u8','%u16','%u32','%u64','%f','%f32','%f64','%n','%L','%s','%D','%C'};
validFormatSpecClass        = {'int32','int8','int16','int32','int64','uint32','uint8','uint16','uint32','uint64','double','single','double','double','logical','cellstr','datetime','categorical'};
validFormatSpecIsNumeric    = [true,true,true,true,true,true,true,true,true,true,true,true,true,true,false,false,false,false];
validFormatSpecRE           = {'^%d$','%^d8$','^%d16$','^%d32$','^%d64$','^%u$','^%u8$','^%u16$','^%u32$','^%u64$','^%f$','^%f32$','^%f64$','^%n$','^%L$','^%s$','^%D$','^%C$'};
nValidFormatSpecs           = numel(validFormatSpecRE);

[validClasses,indU1,indU2] 	= unique(validFormatSpecClass,'stable');
validClassesIsNumeric       = validFormatSpecIsNumeric(indU1);
nValidClasses               = numel(validClasses);

% check formatSpec input
maskFormatSpec     	= false(nValidFormatSpecs,nColumns);
tokens              = cell(nValidFormatSpecs,nColumns);
for fs = 1:nValidFormatSpecs
    [tmp1,tokens(fs,:)]  	= regexp(VarFormat,validFormatSpecRE{fs},'start','tokens','forceCellOutput');
    maskFormatSpec(fs,:)  	= ~cellfun(@isempty,tmp1);
end

indUnknownFormatSpec    = find(sum(maskFormatSpec) ~= 1,1);
if ~isempty(indUnknownFormatSpec)
    error('Dingi:DataKit:importTableFile:noValidFormatSpecFound',...
        '''%s'' is not a valid formatSpec in file:\n\t%s\nValid formatSpecs are:\n\t%s',VarFormat{indUnknownFormatSpec},filename,strjoin(validFormatSpec,'\n\t'))
end

% initialize
validClassesCount       = accumarray(indU2,sum(maskFormatSpec,2),[nValidClasses,1],@sum);
occuringClassesInd   	= find(validClassesCount > 0);
occuringClassesN        = numel(occuringClassesInd);
occuringClasses         = validClasses(occuringClassesInd);

classCell           = cell(occuringClassesN,1);
classCellColumns    = cell(occuringClassesN,1);

for cl = 1:occuringClassesN
    maskColumns     = any(maskFormatSpec(indU2 == occuringClassesInd(cl),:));
    classCellColumns{cl}    = find(maskColumns);
    if validClassesIsNumeric(occuringClassesInd(cl))
        switch validClasses{occuringClassesInd(cl)}
            case {'single','double'}
                classCell{cl} = NaN(nRows,1,validClasses{occuringClassesInd(cl)});
            otherwise
                classCell{cl} = zeros(nRows,1,validClasses{occuringClassesInd(cl)});
        end
    else
        switch validClasses{occuringClassesInd(cl)}
            case 'logical'
                classCell{cl} = false(nRows,1);
            case 'cellstr'
                classCell{cl} = repmat({''},nRows,1);
            case 'datetime'
                classCell{cl} = NaT(nRows,1,'Format','dd.MM.yyyy HH:mm:ss');
            case 'categorical'
                classCell{cl} = categorical(NaN(nRows,1));
            otherwise
                error('''%s'' needs implementing',occuringClasses{cl})
        end
    end
end
tbl         = table(classCell{:});

[tmpInd1,~]	= find(maskFormatSpec);
[tmpInd2,~]	= find(indU2(tmpInd1)' == occuringClassesInd);
tbl         = tbl(:,tmpInd2);
tbl.Properties.VariableNames            = VarName;
tbl.Properties.VariableDescriptions     = VarDesc;
tbl.Properties.VariableUnits            = VarUnit;



% removes empty data
maskNoData              = cellfun(@(x) isempty(x) || strcmp(x,'NaN') || strcmp(x,'NaT'),raw);
maskColContainsNoData   = all(maskNoData);


% distribute contents
for col = 1:nColumns
    columnClassInd	= indU2(maskFormatSpec(:,col));
    columnClass     = validClasses{columnClassInd};

    if maskColContainsNoData(col)
        continue
    end

    try
        if validClassesIsNumeric(columnClassInd)
            data = cat(1,raw{~maskNoData(:,col),col});
        else
            switch columnClass
                case 'logical'
                    data = logical(cat(1,raw{~maskNoData(:,col),col}));
                case 'cellstr'
                    data = raw(~maskNoData(:,col),col);
                    if ~iscell(data)
                        if isnumeric(data)
                            data = arrayfun(@(x) num2str(x,'%g'),data,'un',0);
                        else
                        	error('Dingi:DataKit:importTableFile:TODO',...
                            'TODO: implement this!')
                        end
                    else
                        if ~all(cellfun(@ischar,data)) % no reshaping needed, since we always look at a single column
                            error('Dingi:DataKit:importTableFile:TODO',...
                              'TODO: implement this!')
                        end
                    end
                case 'datetime'
                    data    = datetime(cat(1,raw{~maskNoData(:,col),col}),'ConvertFrom','excel');
                case 'categorical'
                    data = raw(~maskNoData(:,col),col);
                    if iscell(data) && ~all(cellfun(@ischar,data))
                        data = categorical(cat(1,data{:}));
                    else
                        data = categorical(data);
                    end
                otherwise
                    error('Dingi:DataKit:importTableFile:TODO',...
                      'TODO: ''%s'' needs implementing',columnClass)
            end
        end
    catch ME
        switch ME.identifier
            otherwise
                rethrow(ME)
        end
    end

    try
        tbl{~maskNoData(:,col),col}     = data;
    catch ME
        switch ME.identifier
            otherwise
                rethrow(ME)
        end
    end
end
end
