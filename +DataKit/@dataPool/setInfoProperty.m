function obj = setInfoProperty(obj,pool,idx,property,value)

    validProperties = properties(obj.Info(pool));
    if ~ismember(property,validProperties)
        error('Dingi:DataKit:dataPool:setInfoProperty:invalidProperty',...
            '''%s'' is not a valid info property.\nValid properties are:\n\t%s',property,strjoin(validProperties,'\n\t'))
    end
    
    obj.Info(pool).(property)(idx) = value;
end