function obj = validateProperties(obj)
    

    obj = validateProperty(obj,'VariableType','Dependant');
    obj = validateProperty(obj,'VariableFactor',1);
    obj = validateProperty(obj,'VariableOffset',0);
    obj = validateProperty(obj,'VariableDescription',{''});
    obj = validateProperty(obj,'VariableMeasuringDevice',GearKit.measuringDevice());
end

function obj = validateProperty(obj,prop,default)
    propCount   = numel(obj.(prop));
    if propCount ~= obj.VariableCount
        if propCount == 0
            % set all to default value
            obj.(prop)(1:obj.VariableCount)	= default;
        elseif propCount < obj.VariableCount
            % only set the unset values to the default value
            obj.(prop)(propCount + 1:obj.VariableCount) = default;
        end
    end
end