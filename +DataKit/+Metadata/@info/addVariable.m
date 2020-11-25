function obj = addVariable(obj,variable,varargin)
    

    variableCount   = numel(variable);
    
    % parse Name-Value pairs
    optionName          = {'VariableType','VariableRaw','VariableFactor','VariableOffset','VariableCalibrationFunction','VariableOrigin','variableDescription','variableMeasuringDevice'}; % valid options (Name)
    optionDefaultValue  = {repmat({'Dependant'},1,variableCount),repmat(DataKit.Metadata.variable.undefined,1,variableCount),ones(1,variableCount),zeros(1,variableCount),repmat({@(t,x) x},1,variableCount),repmat({0},1,variableCount),repmat({''},1,variableCount),repmat(GearKit.measuringDevice(),1,variableCount)}; % default value (Value)
    [variableType,...
     variableRaw,...
     variableFactor,...
     variableOffset,...
     variableCalibrationFunction,...
     variableOrigin,...
     variableDescription,...
     variableMeasuringDevice...
        ]               = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    obj.Variable                    = cat(2,obj.Variable,variable);
    obj.VariableRaw                 = cat(2,obj.VariableRaw,variableRaw);
    obj.VariableType                = cat(2,obj.VariableType,variableType);
    obj.VariableFactor              = cat(2,obj.VariableFactor,variableFactor);
    obj.VariableOffset              = cat(2,obj.VariableOffset,variableOffset);
    obj.VariableCalibrationFunction	= cat(2,obj.VariableCalibrationFunction,variableCalibrationFunction);
    obj.VariableOrigin              = cat(2,obj.VariableOrigin,variableOrigin);
    obj.VariableDescription         = cat(2,obj.VariableDescription,variableDescription);
    obj.VariableMeasuringDevice     = cat(2,obj.VariableMeasuringDevice,variableMeasuringDevice);
    
    obj = obj.validateProperties;
    obj.validateInfoObj;
end