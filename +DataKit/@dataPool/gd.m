function [data,info] = gd(obj,type,variable,varargin)


    % parse Name-Value pairs
    optionName          = {'ReturnAbsoluteValues','Raw','DataPoolIdx'}; % valid options (Name)
    optionDefaultValue  = {false,false,[]}; % default value (Value)
    [...
     returnAbsoluteValues,...	% return data with the dataOrigin taken into account
     raw,...                 	% return uncalibrated data
     dataPoolIdx...             % return only data from the specified data pool
     ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    if exist('type','var') ~= 1
        % argument 'type' was not supplied. All available variable types
        % are returned.
        maskIndex       = true(size(obj.Index,1),1);
    else
        if isempty(type)
            % argument 'type' was supplied but empty. All available
            % variable types are returned.
            maskIndex       = true(size(obj.Index,1),1);
        else
            if ~ischar(type)
                % argument 'type' was supplied but is of the wrong data type
                error('DataKit:dataPool:gd:invalidInputTypeForType',...
                    'The input argument ''type'' has to be either empty or a char vector.')
            end
            % argument 'type' was supplied and is of the correct data type
            % mask the data pool array's index rows that contain variables of
            % type 'type' (e.g. Independant or Dependant).
            maskIndex       = obj.Index{:,'VariableType'} == type;
        end
    end
    
    if ~isempty(dataPoolIdx)
        dataPoolIdx = reshape(dataPoolIdx,1,[]);
        maskIndex	= maskIndex & any(obj.Index{:,'DataPool'} == dataPoolIdx,2);
    end
    
    if exist('variable','var') ~= 1
        % argument 'variable' was not supplied. All available variables are
        % returned.
        maskIndex  	= maskIndex & true(size(obj.Index,1),1);
      	variable	= unique(variable2str(obj.Index{maskIndex,'Variable'}));
    else
        if isempty(variable)
            % argument 'variable' was supplied but empty. All available
            % variables are returned.
            maskIndex	= maskIndex & true(size(obj.Index,1),1);
            variable	= unique(variable2str(obj.Index{maskIndex,'Variable'}));
        else
            if ischar(variable) || iscellstr(variable)
                if ischar(variable)
                    variable    = cellstr(variable);
                end
                variable	= variable(:);
                [requestedVariableIsValid,requestedVariableInfo]    = DataKit.Metadata.variable.validateStr(variable);
            elseif isnumeric(variable)
                variable	= variable(:);
                [requestedVariableIsValid,requestedVariableInfo]    = DataKit.Metadata.variable.validateId(variable);
            else
                % argument 'maskIndex' was supplied but is of the wrong data type
                error('DataKit:dataPool:gd:invalidInputTypeForVariable',...
                    'The input argument ''variable'' has to be either empty or resolve to a valid variable')
            end
            % argument 'variable' was supplied and is of the correct data type
            % mask the data pool array's index rows that contain variables
            % 'variable'.
            variable    = variable2str(requestedVariableInfo{requestedVariableIsValid,'Variable'});
            tmp         = arrayfun(@(v) obj.Index{:,'Variable'} == v,variable,'un',0);
            maskIndex	= maskIndex & any(cat(2,tmp{:}),2);
            nRequestedVariables = numel(requestedVariableIsValid);
        end
    end
    
    
    
    
    requestedVariableIsInDataPool   = ismember(variable,variable2str(obj.Index{maskIndex,'Variable'}));
    if ~all(requestedVariableIsInDataPool)
        error('DataKit:dataPool:gd:unavailableVariableRequested',...
            'The requested variable ''%s'' in combination with the requested data type is not available in the data pool.',variable{find(~requestedVariableIsInDataPool,1)})
    end
    
    % find the data pool and variable index of those entries
    maskDataPool    = obj.Index{maskIndex,'DataPool'};
    maskVariable    = obj.Index{maskIndex,'VariableIndex'};
    
    % get a list of unique variables that exist in the data pool array
    [uVariablesInDataPool,~,uVariablesInDataPoolIdx]	= unique(variable2str(obj.Index{maskIndex,'Variable'}));
    nUVariablesInDataPool                               = numel(uVariablesInDataPool);
    
    % accumulate relevant data in a cell array where the rows are the data
    % pools and the columns the unique variables
    data            = cell(obj.PoolCount,nUVariablesInDataPool);
    dataIdx     	= sub2ind([obj.PoolCount,nUVariablesInDataPool],maskDataPool,uVariablesInDataPoolIdx);
    variableIdx     = sub2ind([1,nUVariablesInDataPool],ones(numel(uVariablesInDataPoolIdx),1),uVariablesInDataPoolIdx);
    dataPoolIdx     = sub2ind([obj.PoolCount,1],maskDataPool,ones(numel(uVariablesInDataPoolIdx),1));
    
    if raw
        data(dataIdx)	= cellfun(@(d,dp,var) cat(2,d,dp(:,var)),...
                            reshape(data(dataIdx),[],1),...
                            reshape(obj.DataRaw(maskDataPool),[],1),...
                            num2cell(variableIdx),...
                          'un',0);
    else
        data(dataIdx)	= cellfun(@(d,dp,var) cat(2,d,dp(:,var)),...
                            reshape(data(dataIdx),[],1),...
                            reshape(obj.Data(maskDataPool),[],1),...
                            num2cell(variableIdx),...
                          'un',0);
    end
    
    % accumulate information
    dataPoolMeta                        = obj.info;
    info                                = struct();
    info.Variable                       = repmat(DataKit.Metadata.variable.undefined,1,nUVariablesInDataPool);
    info.VariableType                   = repmat(DataKit.Metadata.validators.validInfoVariableType.undefined,1,nUVariablesInDataPool);
    info.VariableOrigin                 = cell(obj.PoolCount,nUVariablesInDataPool);
    info.MeasuringDevice                = repmat(GearKit.measuringDevice(),obj.PoolCount,1);
    info.Variable(variableIdx)        	= obj.Index{maskIndex,'Variable'};
    info.VariableType(variableIdx)     	= obj.Index{maskIndex,'VariableType'};
    info.VariableOrigin(dataIdx)        = dataPoolMeta{maskIndex,'Origin'};
    info.MeasuringDevice(dataPoolIdx) 	= obj.Index{maskIndex,'MeasuringDevice'};
    
    if returnAbsoluteValues
        originIsDatetime            = cellfun(@isdatetime,info.VariableOrigin);
        if any(originIsDatetime(:))
            data(originIsDatetime)	= cellfun(@(v,o) o + seconds(v),data(originIsDatetime),info.VariableOrigin(originIsDatetime),'un',0);
        end
        if any(~originIsDatetime(:))
            data(~originIsDatetime)	= cellfun(@(v,o) o + v,data(~originIsDatetime),info.VariableOrigin(~originIsDatetime),'un',0);
        end
    end
end