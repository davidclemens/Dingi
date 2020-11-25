function obj = updateVariableRaw(obj)

    obj.VariableRaw(~obj.VariableIsCalibrated) = DataKit.Metadata.variable.undefined;
end