function obj = core_fromProperty(className,propertyName,values)

    import DataKit.enum.validateClassName
    import DataKit.enum.validatePropertyName
    import DataKit.enum.validatePropertyValues
    import DataKit.enum.listValidPropertyValues
    
    className           = validateClassName(className);
    propertyName        = validatePropertyName(className,propertyName);
    propertyValues      = validatePropertyValues(className,propertyName,values);
        
    szValues            = size(propertyValues);
    propertyValues      = reshape(propertyValues,[],1);
    
    enumerationMembers	= enumeration(className);
    
    % Get valid property values
    validPropertyValues = listValidPropertyValues(className,propertyName);
    
    [~,imInd]   = ismember(propertyValues,validPropertyValues);
    
    % Reshape to value shape
    obj         = reshape(enumerationMembers(imInd),szValues);
end