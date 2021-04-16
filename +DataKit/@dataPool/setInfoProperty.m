function varargout = setInfoProperty(obj,pool,idx,property,value)

    nargoutchk(0,1)
    
    validProperties = properties(obj.Info(pool));
    if ~ismember(property,validProperties)
        error('Dingi:DataKit:dataPool:setInfoProperty:invalidProperty',...
            '''%s'' is not a valid info property.\nValid properties are:\n\t%s',property,strjoin(validProperties,'\n\t'))
    end
    
    obj.Info(pool).(property)(idx) = value;
    
    obj.IndexNeedsUpdating = true;
    
    if nargout == 1
        varargout{1} = obj;
    end
end