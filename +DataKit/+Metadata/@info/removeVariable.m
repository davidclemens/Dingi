function obj = removeVariable(obj,ind)

    obj.Variable(ind)                       = [];
    obj.VariableRaw(ind)                	= [];
    obj.VariableType(ind)                   = [];
    obj.VariableDescription(ind)            = [];
    obj.VariableFactor(ind)             	= [];
    obj.VariableOffset(ind)             	= [];
    obj.VariableOrigin(ind)                 = [];
    obj.VariableCalibrationFunction(ind)	= [];
    obj.VariableMeasuringDevice(ind)        = [];
end