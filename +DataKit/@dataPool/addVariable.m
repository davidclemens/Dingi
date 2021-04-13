function varargout = addVariable(obj,variable,data,varargin)
% addVariable  Adds a variable to a pool of a dataPool instance
%   ADDVARIABLE adds a variable to the pool pool of the dataPool instance
%	obj.
%
%   Syntax
%     ADDVARIABLE(obj,variable,data)
%     ADDVARIABLE(__,Name,Value)
%     obj = ADDVARIABLE(__)
%
%   Description
%     ADDVARIABLE(obj,variable,data)
%     ADDVARIABLE(__,Name,Value)
%     obj = ADDVARIABLE(__)
%
%   Example(s)
%     ADDVARIABLE(dp,'Oxygen',data)
%
%
%   Input Arguments
%     obj - data pool instance
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%     variable - variable
%       char vector | cellstr
%         List of variables corresponding to data, uncertainty & flag (if
%         specified).
%
%     data - data
%       2D array
%         Data
%
%
%   Output Arguments
%     obj - returned data pool instance
%       DataKit.dataPool
%         The new instance of the DataKit.dataPool class.
%
%
%	Name-Value Pair Arguments
%     Pool - pool index
%       0 (default) | numeric scalar
%         The index of the pool to which the variable(s) should be added.
%         If Pool is set to 0 (default) a new pool is added with the new
%         variable(s).
%
%     Uncertainty - data uncertainty
%       2D array
%         Sets the absolute data uncertainty. Default is all zeros.
%
%     Flag - data flags
%       2D array | DataKit.Metadata.dataFlag
%         Sets data flags. See the dataFlag documentation.
%
%     VariableType - variable type
%       'Dependent' (default) | 'Independent'
%         Sets the variable type. Has to have the same size as variable.
%
%     VariableCalibrationFunction - variable calibration function
%       @(t,x) x (default) | cell vector of function handles
%         Sets the variable calibration function. Has to have the same size
%         as variable.
%
%     VariableOrigin - variable origin
%       {0} (default) | cell vector
%         Sets the variable origin. All data is stored as doubles relative
%         to the variable origin. Has to have the same size as variable.
%
%     VariableDescription - variable description
%       '' (default) | cellstr
%         Sets the variable description. Has to have the same size as
%         variable.
%
%     VariableMeasuringDevice - variable measuring device
%       GearKit.measuringDevice
%         Sets the variable measuring device. Has to have the same size as
%         variable.
%
%   See also DATAPOOL, DATAFLAG
%
%   Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
%

    import DataKit.Metadata.dataFlag
    import internal.stats.parseArgs
    
    % Input checks
    narginchk(3,inf)
    nargoutchk(0,1)

    if isempty(variable)
        error('Dingi:DataKit:dataPool:addVariable:emptyVariable',...
            'The provided variable(s) can''t be empty.')
    end
    if isempty(data)
        error('Dingi:DataKit:dataPool:addVariable:emptyData',...
            'The provided data can''t be empty.')
    end
    if ischar(variable)
        variable    = cellstr(variable);
    end
    if numel(variable) ~= size(data,2)
        error('Dingi:DataKit:dataPool:addVariable:variableDataSizeMismatch',...
            'The number of variables has to match the number of data columns.')
    end

    %   parse Name-Value pairs
    optionName          = {'Pool','Uncertainty','Flag','VariableType','VariableCalibrationFunction','VariableOrigin','VariableDescription','VariableMeasuringDevice'}; %   valid options (Name)
    optionDefaultValue  = {0,0,0,{'Dependent'},{@(t,x) x},{0},{''},GearKit.measuringDevice()}; %   default value (Value)
    [pool,...
     uncertainty,...
     flag,...
     variableType,...
     variableCalibrationFunction,...
     variableOrigin,...
     variableDescription,...
     variableMeasuringDevice...
        ]               = parseArgs(optionName,optionDefaultValue,varargin{:}); %   parse function arguments

    % Decide to which pool the variable(s) should be added.
    if pool <= 0
   	% Add variable(s) to a new pool
        obj.addPool;
        pool = obj.PoolCount;
    elseif pool > 0 && pool <= obj.PoolCount
   	% Add variable(s) to existing pool
    elseif pool > 0 && pool > obj.PoolCount
    % Add variables(s) to a new pool
        obj.addPool;
        pool = obj.PoolCount;
    end

    if size(data,3) > 2
        error('Dingi:DataKit:dataPool:addVariable:invalidDimensionsOfNewData',...
            'New data has wrong dimensions.')
    end

    nSamples            = size(obj.DataRaw{pool},1);
    nVariables          = size(obj.DataRaw{pool},2);
    nSamplesNew         = size(data,1);
    nVariablesNew       = size(data,2);

    % Shape uncertainty and flag inputs
    if isscalar(uncertainty)
        if issparse(uncertainty)
            uncertainty = repmat(uncertainty,nSamplesNew,nVariablesNew);
        else
            uncertainty = repmat(sparse(uncertainty),nSamplesNew,nVariablesNew);
        end
    elseif ~isscalar(uncertainty)
        if all(size(uncertainty) == size(data))
            if ~issparse(uncertainty)
                uncertainty = sparse(uncertainty);
            end
        else
            error('Dingi:DataKit:dataPool:addVariable:invalidUncertaintyShape',...
                'New data uncertainty needs to have the same number of samples (%u) and variables (%u) as the new data for the data pool. It has %u and %u instead.',nSamplesNew,nVariablesNew,size(uncertainty,1),size(uncertainty,2))
        end
    end
    if isscalar(flag)
        if isa(flag,'DataKit.Metadata.dataFlag')
            flag = repmat(flag,nSamplesNew,nVariablesNew);
        else
            flag = dataFlag(repmat(flag,nSamplesNew,nVariablesNew));
        end
    elseif ~isscalar(flag)
        if all(size(flag) == size(data))
            if ~isa(flag,'DataKit.Metadata.dataFlag')
                flag = dataFlag(flag);
            end
        else
            error('Dingi:DataKit:dataPool:addVariable:invalidFlagShape',...
                'New data flag needs to have the same number of samples (%u) and variables (%u) as the new data for the data pool. It has %u and %u instead.',nSamplesNew,nVariablesNew,size(flag,1),size(flag,2))
        end
    end
    
    if nVariables == 0
        % there is no data in the data pool yet
     	obj.DataRaw{pool}       = data;
     	obj.Data{pool}          = data;
    	obj.Flag{pool}          = flag;
       	obj.Uncertainty{pool}   = uncertainty;
    else
        % there is already data in the data pool
        if nSamplesNew ~= nSamples
            error('Dingi:DataKit:dataPool:addVariable:invalidNumberOfSamples',...
                'New data needs to have the same number of samples (%u) as the existing data in the data pool. It has %u instead.',nSamples,nSamplesNew)
        end
        obj.DataRaw{pool}       = cat(2,obj.DataRaw{pool},data);
     	obj.Data{pool}          = cat(2,obj.Data{pool},data);
    	obj.Flag{pool}          = cat(2,obj.Flag{pool},flag);
      	obj.Uncertainty{pool}	= cat(2,obj.Uncertainty{pool},uncertainty);
    end

    obj.Info(pool).addVariable(variable,...
        'VariableType',                 variableType,...
        'VariableCalibrationFunction', 	variableCalibrationFunction,...
        'VariableOrigin',               variableOrigin,...
        'VariableDescription',          variableDescription,...
        'VariableMeasuringDevice',      variableMeasuringDevice);

	for vv = 1:nVariablesNew
        obj.applyCalibrationFunction(pool,nVariables + vv);
	end

    obj.IndexNeedsUpdating = true;
    
    if nargout == 1
        varargout{1} = obj;
    end
end
