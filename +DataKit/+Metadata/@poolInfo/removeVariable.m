function varargout = removeVariable(obj,ind)

    nargoutchk(0,1)
    
    obj.Variable(ind)                       = [];
    obj.VariableRaw(ind)                	= [];
    obj.VariableType(ind)                   = [];
    obj.VariableDescription(ind)            = [];
    obj.VariableFactor(ind)             	= [];
    obj.VariableOffset(ind)             	= [];
    obj.VariableOrigin(ind)                 = [];
    obj.VariableCalibrationFunction(ind)	= [];
    obj.VariableMeasuringDevice(ind)        = [];
    
    if nargout == 1
        varargout{1} = obj;
    end
end