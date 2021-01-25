function obj = core_fromProperty(classname,propertyname,value)

    validProperties     = properties(classname);
    if isempty(validProperties)
        error('Dingi:DataKit:enum:core_fromProperty:noAttributesAvailable',...
            'There are no attributes defined for class ''%s''.',classname)
    end
    propertyname        = validatestring(propertyname,validProperties);
    
    members             = enumeration(classname);
    validPropertyValues = {members.(propertyname)}';
    propertyValue       = validatestring(value,validPropertyValues);
    
    im  = ismember(validPropertyValues,propertyValue);
    obj = members(im);
end