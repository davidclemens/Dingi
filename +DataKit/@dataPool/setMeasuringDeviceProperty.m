function obj = setMeasuringDeviceProperty(obj,pool,idx,property,value)

    validProperties = properties(obj.Info(pool).VariableMeasuringDevice(idx));
    if ~ismember(property,validProperties)
        error('DataKit:dataPool:setMeasuringDeviceProperty:invalidProperty',...
            '''%s'' is not a valid measuring device property.\nValid properties are:\n\t%s',property,strjoin(validProperties,'\n\t'))
    end
    
    obj.Info(pool).VariableMeasuringDevice(idx).(property) = value;
end