function data = fetchData(obj,variable,varargin)
% fetchData  Retrieve deployment data
%   
%
%   Copyright (c) 2020-2022 David Clemens (dclemens@geomar.de)
%
        
    import DataKit.importTableFile
    
    % parse Name-Value pairs
    optionName          = {'Raw','DeploymentDataOnly','TimeOfInterestDataOnly','RelativeTime','GroupBy'}; % valid options (Name)
    optionDefaultValue  = {false,false,false,'',''}; % default value (Value)
    [...
     raw,...                        % return uncalibrated data
     deploymentDataOnly,...         % only keep time series data that's within the deployment & recovery times
     timeOfInterestDataOnly,...     % only keep time series data that's within the time of interest times
     relativeTime,...               % return time as relative time (y, d, h, m, s, ms) or datetime (dt)
     groupBy...
     ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
 
    % input check: obj
	if numel(obj) > 1
        error('Dingi:GearKit:gearDeployment:fetchData:objSize',...
         	'fetchData only works in a scalar context. To fetch data from multiple instances, loop over all.')
	end
    
    % input check: deploymentDataOnly & timeOfInterestDataOnly
    if deploymentDataOnly + timeOfInterestDataOnly > 1
        error('Dingi:GearKit:gearDeployment:fetchData:modalDataOnly',...
            'Only DeploymentDataOnly OR TimeOfInterestDataOnly can be requested. Not both at the same time.')
    end
    
	data	= fetchData(obj.data,variable,...
                'ReturnRawData',	raw,...
                'ForceCellOutput',  true,...
                'GroupBy',          groupBy);
    
    hasData         	= ~cellfun(@isempty,data.IndepInfo.Variable);
    hasTime             = false(size(data.IndepInfo.Variable));
    timeIdx            	= NaN(size(data.IndepInfo.Variable));
    [hasTime(hasData),timeIdx(hasData)]	= cellfun(@(v) ismember('Time',v),data.IndepInfo.Variable(hasData));
    indHasTime          = find(hasTime & hasData);
	nOutputCells        = numel(indHasTime);
    
    if (deploymentDataOnly || timeOfInterestDataOnly)
        if isempty(obj.timeOfInterestStart) || isempty(obj.timeOfInterestEnd) || ...
           isnat(obj.timeOfInterestStart) || isnat(obj.timeOfInterestEnd)
            error('Dingi:GearKit:gearDeployment:fetchData:timeOfInterestMissing',...
                'There is no information on the time of interest for %s.',[char(obj.gear),' (',char(obj.cruise),')'])
        end
        
        if sum(hasTime) == 0
%             warning('Dingi:GearKit:gearDeployment:fetchData:noIndependentVariableTimeFound',...
%                 'If ''DeploymentDataOnly'' or ''TimeOfInterestDataOnly'' are set to true, the requested variable(s) should have an independent variable ''Time''.')
        end
        
        for ii = 1:nOutputCells
            % loop over all output cells
            if deploymentDataOnly
                % loop over all groups
                maskTime  	= cellfun(@(t) t > obj.timeDeployment & ...
                                           t < obj.timeRecovery,data.IndepData{indHasTime(ii)}(:,timeIdx(indHasTime(ii))),'un',0);
            elseif timeOfInterestDataOnly
                maskTime  	= cellfun(@(t) t > obj.timeOfInterestStart & ...
                                           t < obj.timeOfInterestEnd,data.IndepData{indHasTime(ii)}(:,timeIdx(indHasTime(ii))),'un',0);
            end
            
            data.IndepData{indHasTime(ii)}(:,timeIdx(indHasTime(ii)))	= cellfun(@(v,m) v(m),data.IndepData{indHasTime(ii)}(:,timeIdx(indHasTime(ii))),maskTime,'un',0);
            data.DepData(indHasTime(ii))                                = cellfun(@(v,m) v(m,:),data.DepData(indHasTime(ii)),maskTime,'un',0);
            data.Flags(indHasTime(ii))                                  = cellfun(@(v,m) v(m,:),data.Flags(indHasTime(ii)),maskTime,'un',0);
        end
    end

    
  	nHasTime = sum(hasTime(hasData));
    if ~isempty(relativeTime) && nHasTime >= 1
        timeAsDatetime  = cellfun(@(iv,ind) iv{ind},data.IndepData(indHasTime),num2cell(timeIdx(indHasTime)),'un',0);
        timeRelative  	= cellfun(@(t) t - obj.timeOfInterestStart,timeAsDatetime,'un',0);
        switch relativeTime
            case 'ms'
                time        = cellfun(@milliseconds,timeRelative,'un',0);
                newVariable = DataKit.Metadata.variable.DurationMs;
            case 's'
                time        = cellfun(@seconds,timeRelative,'un',0);
                newVariable = DataKit.Metadata.variable.DurationS;
            case 'm'
                time        = cellfun(@minutes,timeRelative,'un',0);
                newVariable = DataKit.Metadata.variable.DurationMin;
            case 'h'
                time        = cellfun(@hours,timeRelative,'un',0);
                newVariable = DataKit.Metadata.variable.DurationH;
            case 'd'
                time        = cellfun(@days,timeRelative,'un',0);
                newVariable = DataKit.Metadata.variable.DurationD;
            case 'y'
                time        = cellfun(@years,timeRelative,'un',0);
                newVariable = DataKit.Metadata.variable.DurationY;
            case 'datetime'
                % time is already stored as datetime
                time        = timeAsDatetime;
                newVariable = DataKit.Metadata.variable.Time;
            case 'datenum'
                time        = cellfun(@datenum,timeAsDatetime,'un',0);
                newVariable = DataKit.Metadata.variable.Time;
            otherwise
                error('Dingi:GearKit:gearDeployment:fetchData:unknownRelativeTimeIdentifier',...
                    '''%s'' is an unknown relative time identifier.',relativeTime)
        end
        for tt = 1:nHasTime
            data.IndepData{indHasTime(tt)}(timeIdx(indHasTime(tt)))             = time(tt);
            data.IndepInfo.Variable{indHasTime(tt)}(timeIdx(indHasTime(tt)))    = newVariable;
        end
    end
    

    % make sure the masking didn't result in empty groups
    maskGroupIsNotEmtpy 	= ~all(cellfun(@isempty,data.DepData),2);
    data.IndepData        	= data.IndepData(maskGroupIsNotEmtpy,:);
    data.DepData           	= data.DepData(maskGroupIsNotEmtpy,:);
    data.Flags           	= data.Flags(maskGroupIsNotEmtpy,:);
    data.IndepInfo          = maskStruct(data.IndepInfo,maskGroupIsNotEmtpy,1);
    data.DepInfo            = maskStruct(data.DepInfo,maskGroupIsNotEmtpy,1);
    
    
    % make sure the masking didn't result in empty variables
    maskVariableIsNotEmtpy 	= ~all(cellfun(@isempty,data.DepData),1);
    data.IndepData        	= data.IndepData(:,maskVariableIsNotEmtpy);
    data.DepData           	= data.DepData(:,maskVariableIsNotEmtpy);
    data.Flags           	= data.Flags(:,maskVariableIsNotEmtpy);
    data.IndepInfo          = maskStruct(data.IndepInfo,maskVariableIsNotEmtpy,2);
    data.DepInfo            = maskStruct(data.DepInfo,maskVariableIsNotEmtpy,2);
end

function s = maskStruct(s,mask,varargin)

    narginchk(2,3)
    
    if nargin == 2
        dim = [];
    elseif nargin == 3
        dim = varargin{1};
    end

    fields	= fieldnames(s);
    tmp = struct();
    for ff = 1:numel(fields)
        switch dim
            case 1
                tmp.(fields{ff})	= s.(fields{ff})(mask,:);
            case 2
                tmp.(fields{ff})	= s.(fields{ff})(:,mask);
            otherwise
                tmp.(fields{ff})	= s.(fields{ff})(mask);
        end     
    end
    s       = tmp;
end