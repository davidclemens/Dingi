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
    fseek(fId,0,'bof');

    headerRawText 	= textscan(fId,'%s',nHeaderLines,...
                        'Delimiter',         	'\n');
    
	% Find all rows that are variables
	isVariable      = regexp(headerRawText{:},'^# name \d+ = ');
    isVariable      = ~cellfun(@isempty,isVariable);
    nVars           = sum(isVariable);
    
    % Check if variable unit is defined
    hasUnit         = ~cellfun(@isempty,regexp(headerRawText{:},'\[.+\]$'));
    
    % Get variable Metadata seperately for variables with and without units defined
	tmpVarsWOUnits  = regexp(headerRawText{:}(isVariable & ~hasUnit),'^# name \d{1,2} = (?<VarNameShort>.+):\s{1,2}(?<VarNameLong>[A-Za-z\d\+\-\.\s\/]+)\,?\s?(?<VarDescriptor>.+?)?(?<VarUnits>%)?$','names');
	tmpVarsWUnits   = regexp(headerRawText{:}(isVariable & hasUnit),'^# name \d{1,2} = (?<VarNameShort>.+):\s{1,2}(?<VarNameLong>[A-Za-z\d\+\-\.\s\/]+)\,?\s?(?<VarDescriptor>.+?)?\s?(?<VarUnits>\[.+\])$','names');
    
    % Combine the results
    tmpVariables(find(hasUnit & isVariable) - find(isVariable,1) + 1)     = cat(1,tmpVarsWUnits{:});
    tmpVariables(find(~hasUnit & isVariable) - find(isVariable,1) + 1) 	= cat(1,tmpVarsWOUnits{:});

	tmpStartTime    = regexp(headerRawText{:},'# start_time = ([A-Za-z]{3}\s\d{2}\s\d{4}\s\d{2}:\d{2}:\d{2})','tokens');
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
        SN	= tmpHardware.SerialNumber;
    else
        [~,fn,~] = fileparts(path);
        tmpHardware2 = regexp(fn,'_(?<Model>.+?)_(?<SN>.+?)$','names');
        try
            SN  = tmpHardware2.SN;
        catch
            SN = '';
        end
    end
    measuringDevice.SerialNumber  	= SN;

    variables                   = varNames{1:end,{'VarNameLong','VarNameShort'}};
    [isValid,info]              = validate('Variable',variables);
    info           	= info(:);
    isValid         = isValid(:);

  	unitMatches                 = ~cellfun(@isempty,regexpi(repmat(varNames{:,'VarUnits'},2,1),{info.UnitRegexp}'));
    
    
    if any(sum(isValid,2) > 1)
        error('Both long & short variable names match')
    end
    
    if sum(unitMatches(isValid)) ~= sum(isValid)
        printDebugMessage('Warning','One or more variable was rejected because its unit was not recognized')
    end
    isValid     = reshape(isValid,[],2);
    info        = reshape(info,[],2);
    unitMatches	= reshape(unitMatches,[],2);
    
    isValid                     = isValid & unitMatches;

	if ~all(any(isValid,2))
        printDebugMessage('Warning','The parameter(s):\n\t''%s''\nare not recognized in the DataKit toolbox. They are not imported.',strjoin(strcat(variables(~(any(isValid,2)),1),{', '},variables(~(any(isValid,2)),2)),'\n\t'))
    end
    
    [sortInd,~]             = find(isValid);
    [~,sortInd]             = sort(sortInd);
    tmpVariable(sortInd)  	= cat(1,info(isValid).EnumerationMemberName);
    variables               = tmpVariable;
    timeInd                	= find(variables == 'Time');
	timeIsJulian    = false;
    if isempty(timeInd)
        timeIsJulian        = true;
    	timeInd            	= find(variables == 'TimeJulian');
        variables(timeInd)  = DataKit.Metadata.variable.Time;
        if isempty(timeInd)
            error('No time found')
        end
    end


    variables               = cellstr(variables);
    data                    = cat(2,rawText{any(isValid,2)});
    if timeIsJulian
        data(:,timeInd)       	= (data(:,timeInd) - data(1,timeInd))*24*60*60;
    else
        data(:,timeInd)       	= data(:,timeInd) - data(1,timeInd);
    end
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
