function obj = selectVariable(obj,variableIdx)

    ind = setxor(variableIdx,1:obj.VariableCount);
    obj = obj.removeVariable(ind);
end