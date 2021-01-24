function obj = core_fromProperty(classname,propertyname,value)

    validProperties     = properties(classname);
    propertyname        = validatestring(propertyname,validProperties);
    
    members             = enumeration(classname);
    validPropertyValues = {members.(propertyname)}';
    propertyValue       = validatestring(value,validPropertyValues);
    
    im  = ismember(validPropertyValues,propertyValue);
    obj = members(im);
end