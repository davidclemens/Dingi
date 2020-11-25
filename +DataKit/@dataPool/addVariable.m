function obj = addVariable(obj,pool,variable,data,uncertainty,varargin)

    if ischar(variable)
        variable    = cellstr(variable);
    end
    variableCount   = numel(variable);

    % parse Name-Value pairs
    optionName          = {'VariableType','VariableFactor','VariableOffset','VariableCalibrationFunction','VariableOrigin','variableDescription','variableMeasuringDevice'}; % valid options (Name)
    optionDefaultValue  = {repmat({'Dependant'},1,variableCount),ones(1,variableCount),zeros(1,variableCount),repmat({@(t,x) x},1,variableCount),repmat({0},1,variableCount),repmat({''},1,variableCount),repmat(GearKit.measuringDevice(),1,variableCount)}; % default value (Value)
    [variableType,...
     variableFactor,...
     variableOffset,...
     variableCalibrationFunction,...
     variableOrigin,...
     variableDescription,...
     variableMeasuringDevice...
        ]               = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    if pool > obj.PoolCount
        obj     = obj.addPool;
        warning('DataKit:dataPool:addVariable:poolIndexExceedsPoolCount',...
            'The requested data pool index %u exceeds the data pool count of %u. A new data pool was appended.',pool,obj.PoolCount);
        pool    = obj.PoolCount;
    end
    
    if size(data,3) > 2
        error('DataKit:dataPool:addVariable:invalidDimensionsOfNewData',...
            'New data has wrong dimensions.')
    end
    
    nSamples            = size(obj.DataRaw{pool},1);
    nVariables          = size(obj.DataRaw{pool},2);
    nSamplesNew         = size(data,1);
    nVariablesNew       = size(data,2);
    newDataHasErrorInfo	= ~isempty(uncertainty);
    
    if nVariables == 0
        % there is no data in the data pool yet
     	obj.DataRaw{pool}      = data;
        if newDataHasErrorInfo
            obj.Uncertainty{pool}   = sparse(uncertainty);
        elseif ~newDataHasErrorInfo
            obj.Uncertainty{pool}   = sparse(zeros(size(data)));
        end
    else
        if nSamplesNew ~= nSamples
            error('DataKit:dataPool:addVariable:invalidNumberOfSamples',...
                'New data needs to have the same number of samples (%u) as the existing data in the data pool. It has %u instead.',nSamples,nSamplesNew)
        end
        obj.DataRaw{pool}      = cat(2,obj.DataRaw{pool},data);
        if newDataHasErrorInfo
            obj.Uncertainty{pool}	= cat(2,obj.Uncertainty{pool},sparse(uncertainty));
        elseif ~newDataHasErrorInfo
            obj.Uncertainty{pool}   = cat(2,obj.Uncertainty{pool},sparse(zeros(size(data))));
        end
    end
    
    obj.Info(pool)  = obj.Info(pool).addVariable(variable,...
                        'VariableType',                 variableType,...
                        'VariableFactor',               variableFactor,...
                        'VariableOffset',               variableOffset,...
                        'VariableCalibrationFunction', 	variableCalibrationFunction,...
                        'VariableOrigin',               variableOrigin,...
                        'VariableDescription',          variableDescription,...
                        'VariableMeasuringDevice',      variableMeasuringDevice);
	obj = update(obj);
end