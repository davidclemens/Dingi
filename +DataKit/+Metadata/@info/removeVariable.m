function obj = removeVariable(obj,ind)

    
    obj.VariableType(ind)           = [];
    obj.VariableFactor(ind)         = [];
    obj.VariableOffset(ind)         = [];
    obj.VariableDescription(ind)	= [];
    obj.VariableId(ind)             = [];
end