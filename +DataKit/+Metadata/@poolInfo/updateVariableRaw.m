function varargout = updateVariableRaw(obj)

    nargoutchk(0,1)
    
    obj.VariableRaw(~obj.VariableIsCalibrated) = DataKit.Metadata.variable.undefined;
    
    if nargout == 1
        varargout{1} = obj;
    end
end