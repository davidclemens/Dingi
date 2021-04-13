function varargout = readSeabirdCTD(obj,path)

    import DataKit.Metadata.variable.validate
    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)

    [~,name,ext]   = fileparts(path);
    if strcmp(ext,'.txt')
        tmp                 = regexp(name,'\w+\-\d{2}_([A-Za-z\d\-]+)_([\dA-Za-z]+)','tokens');
        ctdModelName        = tmp{1}{1};
        ctdSerialNumber     = tmp{1}{2};
        obj                 = readSeabirdCTDLegacy(obj,path);

        for var = 1:obj.Info(end).VariableCount
            obj.Info(end).VariableMeasuringDevice(var).SerialNumber = ctdSerialNumber;
        end
        return
    elseif strcmp(ext,'.cnv')
    else
        error('')
    end

    fId             = fopen(path,'r');
    if fId == -1
        printDebugMessage('Warning','Unable to read data in:\n\t ''%s''',path)
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

    % replace bad values with NaN
    rawTextBadMask  = cellfun(@(d) d - badFlag <= 1e-10,rawText,'un',0);
    for ii = 1:numel(rawText)
        rawText{ii}(rawTextBadMask{ii}) = NaN;
    end


    measuringDevice                 = GearKit.measuringDevice();
    measuringDevice.Type            = 'SeabirdCTD';
    if numel(tmpHardware) > 0
        SN            = tmpHardware.SerialNumber;
    else

    end
    measuringDevice.SerialNumber  	= SN;

    variables                   = varNames{1:end,'VarNameLong'};
    [isValid,info]              = validate('Variable',variables);

  	unitMatches                 = ~cellfun(@isempty,regexpi(varNames{:,'VarUnits'},{info.UnitRegexp}'));
    if sum(unitMatches(isValid)) ~= sum(isValid)
        printDebugMessage('Warning','One or more variable was rejected because its unit was not recognized')
    end
    isValid                     = isValid & unitMatches;

	if ~all(isValid)
        printDebugMessage('Warning','The parameter(s):\n\t''%s''\nare not recognized in the DataKit toolbox. They are not imported.',strjoin(variables(~isValid),'\n\t'))
	end

    timeInd                	= find(cat(1,info.Variable) == 'Time');

    variables               = cellstr(cat(1,info(isValid).Variable))';
    data                    = cat(2,rawText{isValid});
    data(:,timeInd)       	= data(:,timeInd) - data(1,timeInd);
    variableType            = repmat({'Dependent'},size(variables));
    variableType(timeInd)   = {'Independent'};
    variableOrigin          = repmat({0},1,size(data,2));
    variableOrigin{timeInd} = startTime;
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));

    obj.addVariable(variables,data,...
        'VariableType',             variableType,...
        'VariableOrigin',           variableOrigin,...
        'VariableMeasuringDevice',	variableMeasuringDevice);

	if nargout == 1
        varargout{1} = obj;
	end
end
