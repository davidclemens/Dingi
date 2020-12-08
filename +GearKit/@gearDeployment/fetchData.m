function data = fetchData(obj,variable,varargin)
% fetchData  Retrieve deployment data
%   
%
%   Copyright 2020 David Clemens (dclemens@geomar.de)
%
        
    import DataKit.importTableFile
    
    % parse Name-Value pairs
    optionName          = {'Raw','DeploymentDataOnly','TimeOfInterestDataOnly','RelativeTime','GroupBy'}; % valid options (Name)
    optionDefaultValue  = {false,false,false,'','Variable'}; % default value (Value)
    [...
     raw,...                        % return uncalibrated data
     deploymentDataOnly,...         % only keep time series data that's within the deployment & recovery times
     timeOfInterestDataOnly,...     % only keep time series data that's within the time of interest times
     relativeTime,...               % return time as relative time (y, d, h, m, s, ms) or datetime (dt)
     groupBy...
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
                'ForceCellOutput',  true,...
                'GroupBy',          groupBy);
    
	nVariables = numel(data.DepData);
    
    maskIndependantVariable    = data.IndepInfo(1).Variable == 'Time';
            
    if maskIndependantVariable && (deploymentDataOnly || timeOfInterestDataOnly)
        if isempty(obj.timeOfInterestStart) || isempty(obj.timeOfInterestEnd) || ...
           isnat(obj.timeOfInterestStart) || isnat(obj.timeOfInterestEnd)
            error('GearKit:gearDeployment:getData:timeOfInterestMissing',...
                'There is no information on the time of interest for %s.',[char(obj.gear),' (',char(obj.cruise),')'])
        end
        
        if sum(maskIndependantVariable) == 0
            error('GearKit:gearDeployment:getData:noIndependantVariableTimeFound',...
                'If ''DeploymentDataOnly'' or ''TimeOfInterestDataOnly'' are set to true, the requested variable is required to have an independant variable ''Time''.')
        end
        
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
            
            data.IndepData{v}	= cellfun(@(v,m) v(m,:),data.IndepData{v},repmat(maskTime,1,numel(maskIndependantVariable)),'un',0);
            data.DepData(v)   	= cellfun(@(v,m) v(m,:),data.DepData(v),maskTime,'un',0);
        end
    end

    % make sure the masking didn't result in empty data
    maskDataPoolIsNotEmtpy 	= ~cellfun(@isempty,data.DepData);
    data.IndepData        	= data.IndepData(maskDataPoolIsNotEmtpy);
    data.DepData           	= data.DepData(maskDataPoolIsNotEmtpy);
    data.IndepInfo          = data.IndepInfo(maskDataPoolIsNotEmtpy);
    data.DepInfo            = data.DepInfo(maskDataPoolIsNotEmtpy);

    
    if maskIndependantVariable && ~isempty(relativeTime)
        timeAsDatetime  = cellfun(@(t) t{maskIndependantVariable},data.IndepData,'un',0);
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
        for ii = 1:numel(data.IndepData)
            data.IndepData{ii}(maskIndependantVariable) = time(ii);
        end
    end
end