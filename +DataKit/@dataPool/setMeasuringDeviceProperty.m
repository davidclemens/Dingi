function varargout = setMeasuringDeviceProperty(obj,pool,idx,property,value)

    nargoutchk(0,1)
    
    if ~isscalar(pool) || ~isscalar(idx) || ...
       (iscellstr(property) && ~isscalar(property))
        error('Dingi:DataKit:dataPool:setMeasuringDeviceProperty:onlyScalar',...
            'Only works in a scalar context.')
    end
    if iscellstr(property) && ~isscalar(property)
        
    end
    
    validProperties = properties(obj.Info(pool).VariableMeasuringDevice(idx));
    if ~ismember(property,validProperties)
        error('Dingi:DataKit:dataPool:setMeasuringDeviceProperty:invalidProperty',...
            '''%s'' is not a valid measuring device property.\nValid properties are:\n\t%s',property,strjoin(validProperties,'\n\t'))
    end
    
    obj.Info(pool).VariableMeasuringDevice(idx).(property) = value;
    
    if nargout == 1
        varargout{1} = obj;
    end
end