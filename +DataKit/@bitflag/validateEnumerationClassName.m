function validEnumerationClassName = validateEnumerationClassName(enumerationClassName)
    
    import DataKit.enum.validateClassName
    import DataKit.enum.validatePropertyName
    import DataKit.enum.listValidPropertyValues
    
    % Test if class name is a valid enumeration class
    validEnumerationClassName = validateClassName(enumerationClassName);
    
    % Test if 'Id' property exists
    hasIdProperty   = strcmp(validatePropertyName(validEnumerationClassName,'Id'),'Id');    
    if ~hasIdProperty
        error('Dingi:DataKit:bitflag:validateEnumerationClassName:idPropertyRequired',...
            'The specified enumeration class ''%s'' is missing an ''Id'' property.',validEnumerationClassName)
    end
    
    % Test if 'Id' property values are numeric
    idPropertyValues    = listValidPropertyValues(validEnumerationClassName,'Id');
    hasNumericIds = isnumeric(idPropertyValues);
    if ~hasNumericIds
        error('Dingi:DataKit:bitflag:validateEnumerationClassName:numericIdsRequired',...
            'The specified enumeration class'' (''%s'') ''Id'' property, is not numeric',validEnumerationClassName)        
    end
    
    % Test if 'Id' property values are unique
    hasUniqueIds = numel(unique(idPropertyValues)) == numel(idPropertyValues);
    if ~hasUniqueIds
        error('Dingi:DataKit:bitflag:validateEnumerationClassName:uniqueIdsRequired',...
            'The specified enumeration class'' (''%s'') ''Id'' property, is not unique',validEnumerationClassName)        
    end
    
    % Test if 'Id' property values have no gaps
    hasNoGaps = all(diff(sort(idPropertyValues)) == 1);
    if ~hasNoGaps
        error('Dingi:DataKit:bitflag:validateEnumerationClassName:idsHaveGap',...
            'The specified enumeration class'' (''%s'') ''Id'' property has gaps.',validEnumerationClassName) 
    end
end