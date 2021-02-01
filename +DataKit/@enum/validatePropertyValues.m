function newPropertyValues = validatePropertyValues(className,propertyName,propertyValues)

    import DataKit.enum.validateClassName
    import DataKit.enum.validatePropertyName
    import DataKit.enum.isValidPropertyValue
    import DataKit.enum.listValidPropertyValues


    className           = validateClassName(className);
    classHierarchy      = strsplit(className,'.');
    classTableName      = [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
    propertyName    	= validatePropertyName(className,propertyName);
    
    enumerationMembers	= enumeration(className);
    enumerationMember 	= enumerationMembers(end);
    
    % Get valid property values
    validPropertyValues = listValidPropertyValues(className,propertyName);
    
    if ischar(propertyValues)
        propertyValues = cellstr(propertyValues);
    end
    szValues    = size(propertyValues);
    propertyValues  = reshape(propertyValues,[],1);
    
    [im,ind] = isValidPropertyValue(className,propertyName,propertyValues);
    
    if any(~im(:))
        invalidInd  = find(~im,1);
        
        % Get valid property strings for error messages
        if strcmp(propertyName,classTableName)
            propertyValuesStr       = propertyValues{invalidInd};
            validPropertyValuesStr  = strjoin(cellstr(enumerationMembers),', ');
        else
            if isnumeric(enumerationMember.(propertyName))
                propertyValuesStr       = mat2str(propertyValues(invalidInd));
                validPropertyValuesStr  = mat2str(unique(validPropertyValues));
            elseif ischar(enumerationMember.(propertyName))
                propertyValuesStr       = propertyValues{invalidInd};
                validPropertyValuesStr  = strjoin(unique(validPropertyValues),', ');
            end
        end
        error('Dingi:DataKit:enum:validatePropertyValues:invalidPropertyValue',...
            '''%s'' is not a valid property value for property ''%s'' of class ''%s''. Valid values are:\n\t%s\n',propertyValuesStr,propertyName,className,validPropertyValuesStr)
    end
    
    newPropertyValues = reshape(validPropertyValues(ind),szValues);
end