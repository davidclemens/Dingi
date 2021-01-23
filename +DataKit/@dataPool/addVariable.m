function obj = addVariable(obj,pool,variable,data,uncertainty,varargin)
% addVariable  Adds a variable to a pool of a dataPool instance
%   ADDVARIABLE adds a variable to the pool pool of the dataPool instance
%	obj.
%
%   Syntax
%     obj = ADDVARIABLE(obj,pool,variable,data,uncertainty)
%     obj = ADDVARIABLE(__,Name,Value)
%     
%   Description
%     obj = ADDVARIABLE(obj,pool,variable,data,uncertainty)
%     obj = ADDVARIABLE(__,Name,Value)
%
%   Example(s)
%     dp = ADDVARIABLE(dp,2,'Oxygen',data,uncertainty)
%
%
%   Input Arguments
%     obj - data pool instance
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%     pool - pool index
%       numeric scalar
%         The index of the pool to which the variable(s) should be added.
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
%     uncertainty - uncertainty
%       2D array
%         Absolute uncertainty of each datapoint in data.
%
%
%   Output Arguments
%
%     obj - returned data pool instance
%       DataKit.dataPool
%         The new instance of the DataKit.dataPool class.
%
%
%	Name-Value Pair Arguments
%     VariableType - variable type
%       'Dependant' (default) | 'Independant'
%         Sets the variable type. Has to have the same size as variable.
%
%     VariableFactor - variable factor
%       1 (default) | numeric vector
%         Sets the variable factor. Has to have the same size as variable.
%
%     VariableOffset - variable offset
%       0 (default) | numeric vector
%         Sets the variable offset. Has to have the same size as variable.
%
%     VariableCalibrationFunction - variable calibration function
%       @(t,x) x (default) | cell vector of function handles
%         Sets the variable calibration function. Has to have the same size
%         as variable.
%
%     VariableOrigin - variable origin
%       0 (default) | cell vector
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
%   See also DATAPOOL
%
%   Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
%

    import DataKit.Metadata.dataFlag
    
    if ischar(variable)
        variable    = cellstr(variable);
    end
    variableCount   = numel(variable);

    %   parse Name-Value pairs
    optionName          = {'VariableType','VariableFactor','VariableOffset','VariableCalibrationFunction','VariableOrigin','VariableDescription','VariableMeasuringDevice'}; %   valid options (Name)
    optionDefaultValue  = {repmat({'Dependant'},1,variableCount),ones(1,variableCount),zeros(1,variableCount),repmat({@(t,x) x},1,variableCount),repmat({0},1,variableCount),repmat({''},1,variableCount),repmat(GearKit.measuringDevice(),1,variableCount)}; %   default value (Value)
    [variableType,...
     variableFactor,...
     variableOffset,...
     variableCalibrationFunction,...
     variableOrigin,...
     variableDescription,...
     variableMeasuringDevice...
        ]               = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); %   parse function arguments
    
    if pool > obj.PoolCount
        obj     = obj.addPool;
        pool    = obj.PoolCount;
    end
    
    if size(data,3) > 2
        error('Dingi:DataKit:dataPool:addVariable:invalidDimensionsOfNewData',...
            'New data has wrong dimensions.')
    end
    
    nSamples            = size(obj.DataRaw{pool},1);
    nVariables          = size(obj.DataRaw{pool},2);
    nSamplesNew         = size(data,1);
    nVariablesNew       = size(data,2);
    newDataHasErrorInfo	= ~isempty(uncertainty);
    
    if nVariables == 0
        % there is no data in the data pool yet
     	obj.DataRaw{pool}  	= data;
     	obj.Data{pool}      = data;
    	obj.Flag{pool}      = dataFlag(size(data,1),size(data,2));
        if newDataHasErrorInfo
            obj.Uncertainty{pool}   = sparse(uncertainty);
        elseif ~newDataHasErrorInfo
            obj.Uncertainty{pool}   = sparse(zeros(size(data)));
        end
    else
        % there is already data in the data pool
        if nSamplesNew ~= nSamples
            error('Dingi:DataKit:dataPool:addVariable:invalidNumberOfSamples',...
                'New data needs to have the same number of samples (%u) as the existing data in the data pool. It has %u instead.',nSamples,nSamplesNew)
        end
        obj.DataRaw{pool} 	= cat(2,obj.DataRaw{pool},data);
     	obj.Data{pool}      = cat(2,obj.Data{pool},data);
    	obj.Flag{pool}      = cat(2,obj.Flag{pool},dataFlag(size(data,1),size(data,2)));
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
                    
	for vv = 1:nVariablesNew
        obj = obj.applyCalibrationFunction(pool,nVariables + vv);
	end
end