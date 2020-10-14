function obj = readSeabirdCTD(obj)

    [~,name,ext]   = fileparts(obj.dataPath);
    if strcmp(ext,'.txt')
        tmp                 = regexp(name,'\w+\-\d{2}_([A-Za-z\d\-]+)_([\dA-Za-z]+)','tokens');
        obj.name            = tmp{1}{1};
        obj.type            = 'ctd';
        obj.serialNumber    = tmp{1}{2};
        obj                 = readSeabirdCTDLegacy(obj);
        return
    elseif strcmp(ext,'.cnv')
    else
        error('')        
    end
    
    fId             = fopen(obj.dataPath,'r');
    if fId == -1
        warning('readSeabirdCTD:unableToOpenFile',...
                'Unable to read %s data in:\n\t ''%s''',obj.id,obj.dataPath)
        return
    end
    
    scanForHeader   = true;
    nHeaderLines    = 0;
    while scanForHeader
        tmp             = fgetl(fId);
        nHeaderLines    = nHeaderLines + 1;
        scanForHeader   = isempty(regexp(tmp,'\*END\*', 'once'));
    end
    headerEnd          = ftell(fId);
    fseek(fId,0,'bof');
    
    
    headerRawText 	= textscan(fId,'%s',nHeaderLines,...
                        'Delimiter',         	'\n');
                    
	isVariable      = regexp(headerRawText{:},'^# name \d+ = ');
    isVariable      = ~cellfun(@isempty,isVariable);
    nVars           = sum(isVariable);
	tmpVars         = regexp(headerRawText{:},'^# name \d+ = (?<VarNameShort>.+):\s{1,2}(?<VarNameLong>[A-Za-z\d\+\-\.\s]+)\,?\s(?<VarDescriptor>.+?)?\s?(?<VarUnits>\[.+\])$','names');
    hasToken        = ~cellfun(@isempty,tmpVars);
	tmpVars         = cat(1,tmpVars{isVariable});
    emptyValue      = repmat({''},nVars,1);
    tmpVariables    = struct('VarNameShort',emptyValue,'VarNameLong',emptyValue,'VarDescriptor',emptyValue,'VarUnits',emptyValue);
    tmpVariables(hasToken(isVariable)) = tmpVars;
    
	tmpStartTime    = regexp(headerRawText{:},'# start_time = (.+) \[.+\]','tokens');
	tmpStartTime  	= cat(1,tmpStartTime{:});
	tmpBadFlag      = regexp(headerRawText{:},'# bad_flag = (.+)','tokens');
	tmpBadFlag  	= cat(1,tmpBadFlag{:});
    tmpHardware   	= regexp(headerRawText{:},'<HardwareData DeviceType=''(?<DeviceType>.+)''\sSerialNumber=''(?<SerialNumber>\d+)''>','names');
	tmpHardware   	= cat(1,tmpHardware{:});
    
    varNames        = struct2table(tmpVariables);
    varNames{:,'VarNameLong'}   = regexprep(lower(varNames{:,'VarNameLong'}),'\s([a-z])','${upper($1)}');
    varNames{:,'VarUnits'}      = regexprep(varNames{:,'VarUnits'},'^\[(.+)\]$','$1');
    
    startTime       = datetime(tmpStartTime{:},'InputFormat','MMM dd yyyy HH:mm:ss');
	badFlag         = str2double(tmpBadFlag{:}{:});
                    
    rawText         = textscan(fId,[repmat('%f',1,nVars),'%f'],...
                        'Delimiter',         	' ',...
                        'MultipleDelimsAsOne',  true,...
                        'EmptyValue',           NaN);
                    
    fclose(fId);
	
    rawTextBadMask  = cellfun(@(d) d - badFlag <= 1e-10,rawText,'un',0);
    for ii = 1:numel(rawText)
        rawText{ii}(rawTextBadMask{ii}) = NaN;
    end
    
    obj.type                    = 'ctd';
    if numel(tmpHardware) > 0
        obj.serialNumber            = tmpHardware.SerialNumber;
    else
        
    end
    
    parameters                  = varNames{1:end,'VarNameLong'};
    [isValid,info]              = DataKit.validateParameter(parameters,...
                                    'Unit',     varNames{1:end,'VarUnits'});
    
    timeInd                     = find(~cellfun(@isempty,regexpi(parameters,'time')),1);
    obj.time                    = datenum(startTime + duration(0,0,rawText{timeInd}) - duration(0,0,rawText{timeInd}(1)));
    obj.data                    = cat(2,rawText{1:numel(parameters)});
  	obj.timeInfo.name           = 'time';
  	obj.timeInfo.timeZone       = 'UTC';
    
    if ~all(isValid)
        warning('GearKit:sensor:readSeabirdCTD:unrecognizedParameter',...
                'The parameter(s):\n\t''%s''\nare not recognized in the DataKit toolbox. It is not imported.\n',strjoin(parameters(~isValid),'\n\t'))
        obj.data                = obj.data(:,isValid);
    end
    obj.dataInfo.id             = info{isValid,'ParameterId'}'; 
end