function [time,varargout] = getData(obj,parameter,varargin)
% GETDATA
        
    import DataKit.importTableFile
    
    % parse Name-Value pairs
    optionName          = {'SensorIndex','SensorId','Raw','DeploymentDataOnly','TimeOfInterestDataOnly','RelativeTime'}; % valid options (Name)
    optionDefaultValue  = {[],'',false,false,false,''}; % default value (Value)
    [sensorIndex,... % only return sensor data from sensors at index within the sensor array
     sensorId,... % only return sensor data from sensors with sensorId
     raw,... % return uncalibrated data
     deploymentDataOnly,... % only keep time series data that's within the deployment & recovery times
     timeOfInterestDataOnly,... % only keep time series data that's within the deployment & recovery times
     relativeTime,... % return time as relative time (y, d, h, m, s, ms) or datetime (dt)
     ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
 
    % input check: obj
	if numel(obj) > 1
        error('GearKit:gearDeployment:getData:objSize',...
         	'getData only works in a scalar context. To get data from multiple instances, loop over all.')
	end
   
    % input check: parameter
    if ischar(parameter)
        parameter	= cellstr(parameter);
    elseif ~iscellstr(parameter)
        error('GearKit:gearDeployment:getData:invalidParameterType',...
         	'The requested parameter has to be specified as a char or cellstr.')
    end
   	parameter	= parameter(:);
    [parameterIsValid,parameterInfo]    = DataKit.validateParameter(parameter);
    nParameter  = sum(parameterIsValid);
    if any(~parameterIsValid)
        warning('GearKit:gearDeployment:getData:someInvalidParameters',...
            'The following requested parameters are invalid:\n\t%s\nThey are ignored.',strjoin(parameter(~parameterIsValid),'\n\t'))
    elseif all(~parameterIsValid)
        error('GearKit:gearDeployment:getData:allInvalidParameters',...
            'All requested parameters are invalid.')        
    end
    
    % input check: deploymentDataOnly & timeOfInterestDataOnly
    if deploymentDataOnly + timeOfInterestDataOnly > 1
        error('GearKit:gearDeployment:getData:modalDataOnly',...
            'Only DeploymentDataOnly OR TimeOfInterestDataOnly can be requested. Not both at the same time.')
    end
    
	% initialize empty meta struct     
    metaEmpty	= struct('dataSourceType',      categorical(NaN),...
                         'dataSourceId',        categorical(NaN),...
                         'dataSourceDomain',    categorical(NaN),...
                         'mountingLocation',    categorical(NaN),...
                         'dependantVariables',  {''},...
                         'name',                {''},...
                         'unit',                {''},...
                         'parameterId',         uint16.empty);
    metaEmpty(:)	= [];
               
	% initialize
    timeSensor      = cell.empty;
    dataSensor      = cell.empty;
    metaSensor      = metaEmpty;
    timeAnalytical  = cell.empty;
    dataAnalytical  = cell.empty;
    metaAnalytical  = metaEmpty;
    
    % get data
    [timeSensor,dataSensor,metaSensor]	= obj.getSensorData(parameterInfo{parameterIsValid,'ParameterId'},...
                                            'SensorIndex',	sensorIndex,...
                                            'SensorId',     sensorId,...
                                            'Raw',        	raw);
    [timeAnalytical,dataAnalytical,metaAnalytical]	= obj.getAnalyticalData(parameterInfo{parameterIsValid,'ParameterId'});

    % merge data
    time    = cat(1,timeSensor,timeAnalytical);
    data    = cat(1,dataSensor,dataAnalytical);
    meta    = cat(1,metaSensor,metaAnalytical);
    
    if ~iscell(time) || isempty(time)
        
    else
        if deploymentDataOnly || timeOfInterestDataOnly
            if isempty(obj.timeOfInterestStart) || isempty(obj.timeOfInterestEnd) || ...
               isnat(obj.timeOfInterestStart) || isnat(obj.timeOfInterestEnd)
                error('GearKit:gearDeployment:getSensorData:timeOfInterestMissing',...
                    'There is no information on the time of interest for %s.',[char(obj.gear),' (',char(obj.cruise),')'])
            end
            if deploymentDataOnly
                maskTime  	= cellfun(@(t) t > datenum(obj.timeDeployment) & ...
                                           t < datenum(obj.timeRecovery),time,'un',0); % initialize
            elseif timeOfInterestDataOnly
                maskTime  	= cellfun(@(t) t > datenum(obj.timeOfInterestStart) & ...
                                           t < datenum(obj.timeOfInterestEnd),time,'un',0); % initialize
            end

            time        = cellfun(@(t,m) t(m),time,maskTime,'un',0);
            data        = cellfun(@(d,m) d(m,:),data,maskTime,'un',0);
        end

        % only keep one copy of the time cell
        [rInd,cInd]	= find(~cellfun(@isempty,time));
        [rInd,uInd] = unique(rInd);
        cInd        = cInd(uInd);
        tInd        = sub2ind(size(time),rInd,cInd);
        time        = time(tInd);

        % add name to meta
        maskDataIsEmpty = cellfun(@isempty,data);
        dataName    = repmat(strcat(cellstr(cat(1,meta.dataSourceId)),{' '},cellstr(cat(1,meta.dataSourceDomain)),{' '}),[1,nParameter]);
        dataName    = strcat(dataName,repmat(parameterInfo{parameterIsValid,'Symbol'}',[size(data,1),1]));
        dataName(maskDataIsEmpty) = {''};
        dataName    = mat2cell(dataName,ones(1,size(dataName,1)));
        [meta.name] = dataName{:};

        % add unit to meta
        dataUnit    = cellstr(repmat(parameterInfo{parameterIsValid,'Unit'}',[size(data,1),1]));
        dataUnit(maskDataIsEmpty) = {''};
        dataUnit    = mat2cell(dataUnit,ones(1,size(dataUnit,1)));
        [meta.unit] = dataUnit{:};
        
        % add parameterId to meta
        dataParameterId     = repmat({parameterInfo{parameterIsValid,'ParameterId'}'},[size(data,1),1]);
        [meta.parameterId]  = dataParameterId{:};

        % make sure the masking didn't result in empty data
        maskTimeIsEmtpy     = cellfun(@isempty,time);
        time                = time(~maskTimeIsEmtpy);
        data                = data(~maskTimeIsEmtpy,:);
        meta                = meta(~maskTimeIsEmtpy);

        if ~isempty(relativeTime)
            timeAsDatetime  = cellfun(@(t) datetime(t,'ConvertFrom','datenum'),time,'un',0);
            timeRelative  	= cellfun(@(t) t - obj.timeOfInterestStart,timeAsDatetime,'un',0);
            switch relativeTime
                case 'ms'
                    time    = cellfun(@milliseconds,timeRelative,'un',0);
                case 's'
                    time    = cellfun(@seconds,timeRelative,'un',0);
                case 'm'
                    time    = cellfun(@minutes,timeRelative,'un',0);
                case 'h'
                    time    = cellfun(@hours,timeRelative,'un',0);
                case 'd'
                    time    = cellfun(@days,timeRelative,'un',0);
                case 'y'
                    time    = cellfun(@years,timeRelative,'un',0);
                case 'datetime'
                    time    = timeAsDatetime;
                case 'datenum'
                    % time is already stored as datenum
                case 'duration'
                    time    = timeRelative;
                otherwise
                    error('GearKit:sensor:gd:unknownRelativeTimeIdentifier',...
                        '''%s'' is an unknown relative time identifier.',relativeTime)
            end
        end
    end
    
    if nargout >= 2
        varargout{1}	= data;
    end
    if nargout >= 3
        varargout{2}    = meta;
    end
end