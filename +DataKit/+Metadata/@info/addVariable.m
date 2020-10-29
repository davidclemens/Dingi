function obj = addVariable(obj,id,varargin)
    

    variableCount   = numel(id);
    % parse Name-Value pairs
    optionName          = {'VariableType','VariableFactor','VariableOffset','variableDescription','variableMeasuringDevice'}; % valid options (Name)
    optionDefaultValue  = {repmat({'Dependant'},1,variableCount),ones(1,variableCount),zeros(1,variableCount),repmat({''},1,variableCount),repmat(GearKit.measuringDevice(),1,variableCount)}; % default value (Value)
    [variableType,...
     variableFactor,...
     variableOffset,...
     variableDescription,...
     variableMeasuringDevice,...
        ]               = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    obj.VariableId              = cat(2,obj.VariableId,id);
    obj.VariableType            = variableType;
    obj.VariableFactor          = variableFactor;
    obj.VariableOffset          = variableOffset;
    obj.VariableDescription     = variableDescription;
    obj.VariableMeasuringDevice	= variableMeasuringDevice;
    
    obj = obj.validateProperties;
end