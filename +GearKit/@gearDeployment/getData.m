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
    nParameter  = numel(parameter);
    
    [parameterIsValid,parameterInfo]    = DataKit.validateParameter(parameter);
               
    % input check: deploymentDataOnly & timeOfInterestDataOnly
    if deploymentDataOnly + timeOfInterestDataOnly > 1
        error('GearKit:gearDeployment:getData:modalDataOnly',...
            'Only DeploymentDataOnly OR TimeOfInterestDataOnly can be requested. Not both at the same time.')
    end
    
	% initialize empty meta struct     
    metaEmpty	= struct('dataSourceType',	categorical(NaN),...
                 'dataSourceId',        categorical(NaN),...
                 'dataSourceDomain',    categorical(NaN),...
                 'mountingLocation',    categorical(NaN),...
                 'dependantVariables',  {''});
    metaEmpty(:)	= [];
               
               
    time    = cell.empty;
    data    = cell.empty;
    meta    = metaEmpty;
    time2   = cell.empty;
    data2   = cell.empty;
    meta2   = metaEmpty;

	if obj.hasSensorData
        im              = ismember(parameterInfo{parameterIsValid,'ParameterId'},obj.parameters{:,'ParameterId'});
        parameterSensor = false(size(parameter));
        parameterSensor(parameterIsValid) = im;
        if any(im)
            [time,data,meta]    = obj.getSensorData(parameterInfo{parameterSensor,'ParameterId'},...
                                    'SensorIndex',	sensorIndex,...
                                    'SensorId',     sensorId,...
                                 	'Raw',        	raw);
        end
	end
    
	if obj.hasAnalyticalData
    	uAnalyticalParameterIds = unique(obj.analyticalSamples{:,'ParameterId'});
        
     	im              = ismember(parameterInfo{parameterIsValid,'ParameterId'},uAnalyticalParameterIds);
        parameterAnalytical= false(size(parameter));
        parameterAnalytical(parameterIsValid) = im;

        if any(im)
            [time2,data2,meta2]    = obj.getAnalyticalData(parameterInfo{parameterAnalytical,'ParameterId'});
        end
	end
    
    time    = cat(1,time,time2);
    data    = cat(1,data,data2);
    meta    = cat(1,meta,meta2);
    

    
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
    
    % TODO
    if nargout >= 2
        varargout{1}	= data;
    end
    if nargout >= 3
        varargout{2}    = meta;
    end
end