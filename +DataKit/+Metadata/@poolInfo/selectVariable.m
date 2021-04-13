function newObj = selectVariable(obj,variableIdx)

    import DataKit.Metadata.poolInfo
    
    newObj = poolInfo(0,obj.Variable(variableIdx),...
        'VariableType',                 obj.VariableType(variableIdx),...
        'VariableCalibrationFunction',  obj.VariableCalibrationFunction(variableIdx),...
        'VariableDescription',          obj.VariableDescription(variableIdx),...
        'VariableMeasuringDevice',      obj.VariableMeasuringDevice(variableIdx));
    
    newObj.VariableFactor   = obj.VariableFactor(variableIdx);
    newObj.VariableOffset   = obj.VariableOffset(variableIdx);
    newObj.VariableOrigin   = obj.VariableOrigin(variableIdx);
end