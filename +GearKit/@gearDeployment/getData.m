function data = getData(obj,variable,varargin)
% GETDATA
        
    import DataKit.importTableFile
    
    % parse Name-Value pairs
    optionName          = {'Raw','DeploymentDataOnly','TimeOfInterestDataOnly','RelativeTime'}; % valid options (Name)
    optionDefaultValue  = {false,false,false,''}; % default value (Value)
    [...
     raw,...                        % return uncalibrated data
     deploymentDataOnly,...         % only keep time series data that's within the deployment & recovery times
     timeOfInterestDataOnly,...     % only keep time series data that's within the time of interest times
     relativeTime,...               % return time as relative time (y, d, h, m, s, ms) or datetime (dt)
     ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
 
    % input check: obj
	if numel(obj) > 1
        error('GearKit:gearDeployment:getData:objSize',...
         	'getData only works in a scalar context. To get data from multiple instances, loop over all.')
	end
    
    % input check: deploymentDataOnly & timeOfInterestDataOnly
    if deploymentDataOnly + timeOfInterestDataOnly > 1
        error('GearKit:gearDeployment:getData:modalDataOnly',...
            'Only DeploymentDataOnly OR TimeOfInterestDataOnly can be requested. Not both at the same time.')
    end
    
	data	= fetchData(obj.data,variable,...
                'ReturnRawData',	raw,...
                'ForceCellOutput',  true);
    
	nVariables = numel(data.DepInfo.Variable);
            
    if deploymentDataOnly || timeOfInterestDataOnly
        if isempty(obj.timeOfInterestStart) || isempty(obj.timeOfInterestEnd) || ...
           isnat(obj.timeOfInterestStart) || isnat(obj.timeOfInterestEnd)
            error('GearKit:gearDeployment:getData:timeOfInterestMissing',...
                'There is no information on the time of interest for %s.',[char(obj.gear),' (',char(obj.cruise),')'])
        end
        maskIndependantVariable    = data.IndepInfo.Variable == 'Time';
        
        for v = 1:nVariables
            % loop over all dependant variables
            if deploymentDataOnly
                % loop over all groups
                maskTime  	= cellfun(@(t) t > obj.timeDeployment & ...
                                           t < obj.timeRecovery,data.IndepData{v}(:,maskIndependantVariable),'un',0);
            elseif timeOfInterestDataOnly
                maskTime  	= cellfun(@(t) t > obj.timeOfInterestStart & ...
                                           t < obj.timeOfInterestEnd,data.IndepData{v}(:,maskIndependantVariable),'un',0);
            end
            
            data.IndepData{v}	= cellfun(@(v,m) v(m,:),data.IndepData{v},maskTime,'un',0);
            data.DepData(v)   	= cellfun(@(v,m) v(m,:),data.DepData(v),maskTime,'un',0);
        end
    end

    % make sure the masking didn't result in empty data
    maskDataPoolIsNotEmtpy     	= any(~cellfun(@isempty,data.IndependantVariables),2);
    data.IndependantVariables   = data.IndependantVariables(maskDataPoolIsNotEmtpy,:);
    data.DependantVariables     = data.DependantVariables(maskDataPoolIsNotEmtpy,:);
    data.IndependantInfo.MeasuringDevice	= data.IndependantInfo.MeasuringDevice(maskDataPoolIsNotEmtpy);
    data.DependantInfo.MeasuringDevice      = data.DependantInfo.MeasuringDevice(maskDataPoolIsNotEmtpy);

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