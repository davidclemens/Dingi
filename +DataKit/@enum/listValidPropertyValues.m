function validPropertyValues = listValidPropertyValues(className,propertyName)

    import DataKit.enum.validateClassName
    import DataKit.enum.validatePropertyName
    import DataKit.enum.core_listMembers
    
    className           = validateClassName(className);
 	classHierarchy      = strsplit(className,'.');
    classTableName      = [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
    
    propertyName        = validatePropertyName(className,propertyName);
    members             = enumeration(className);
    
    if strcmp(classTableName,propertyName)
        validPropertyValues = members;
        return
    else
        memberA             = members(end).(propertyName);
    end
    
    if isnumeric(memberA)
        validPropertyValues     = cat(1,members.(propertyName));
    elseif ischar(memberA)
        validPropertyValues     = {members.(propertyName)}';
    else
        error('Dingi:DataKit:enum:listValidPropertyValues:TODO',...
            'TODO: not implemented yet.')
    end
end