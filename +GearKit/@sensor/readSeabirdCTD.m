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
	tmpVars         = regexp(headerRawText{:},'^# name \d+ = (?<VarNameShort>.+):\s{1,2}(?<VarNameLong>[A-Za-z\d\+\-\.\s]+)\,?\s(?<VarDescriptor>[A-Za-z\s]+)?\s?(?<VarUnits>\[.+\])?$','names');
	tmpVars         = cat(1,tmpVars{:});
	tmpStartTime    = regexp(headerRawText{:},'# start_time = (.+) \[.+\]','tokens');
	tmpStartTime  	= cat(1,tmpStartTime{:});
	tmpBadFlag      = regexp(headerRawText{:},'# bad_flag = (.+)','tokens');
	tmpBadFlag  	= cat(1,tmpBadFlag{:});
    tmpHardware   	= regexp(headerRawText{:},'<HardwareData DeviceType=''(?<DeviceType>.+)''\sSerialNumber=''(?<SerialNumber>\d+)''>','names');
	tmpHardware   	= cat(1,tmpHardware{:});
    
    varNames        = struct2table(tmpVars);
    varNames{:,'VarNameLong'}   = regexprep(lower(varNames{:,'VarNameLong'}),'\s([a-z])','${upper($1)}');
    varNames{:,'VarUnits'}      = regexprep(varNames{:,'VarUnits'},'^\[(.+)\]$','$1');
    
    startTime       = datetime(tmpStartTime{:},'InputFormat','MMM dd yyyy HH:mm:ss');
	badFlag         = str2double(tmpBadFlag{:}{:});
	nVars           = numel(tmpVars);
                    
    rawText         = textscan(fId,[repmat('%f',1,nVars),'%f'],...
                        'Delimiter',         	' ',...
                        'MultipleDelimsAsOne',  true,...
                        'EmptyValue',           badFlag);
                    
    fclose(fId);
                
    obj.type                    = 'ctd';
    obj.serialNumber            = tmpHardware.SerialNumber;
    obj.time                    = datenum(startTime + duration(0,0,rawText{1}) - duration(0,0,rawText{1}(1)));
    obj.data                    = cat(2,rawText{2:end - 1});
  	obj.timeInfo.name           = 'time';
  	obj.timeInfo.timeZone       = 'UTC';
    
    parameters                  = varNames{2:end,'VarNameLong'};
    [isValid,info]              = DataKit.validateParameter(parameters);
    if ~all(isValid)
        warning('GearKit:sensor:readSeabirdCTD:unrecognizedParameter',...
                'The parameter(s):\n\t''%s''\nare not recognized in the DataKit toolbox. It is not imported.\n',strjoin(parameters(~isValid),'\n\t'))
        obj.data                = obj.data(:,isValid);
    end
    obj.dataInfo.id             = info{isValid,'ParameterId'}'; 
end