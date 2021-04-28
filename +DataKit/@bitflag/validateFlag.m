function validFlagId = validateFlag(enumerationClassName,flag)

    import DataKit.enum.validatePropertyValues
    
    if ischar(flag)
        flag = cellstr(flag);
    end
    
    if isnumeric(flag)
        validFlagId     = validatePropertyValues(enumerationClassName,'Id',flag);
    elseif iscellstr(flag)
        classHierarchy 	= strsplit(enumerationClassName,'.');
        classTableName 	= [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
        flagObj         = validatePropertyValues(enumerationClassName,classTableName,flag);
        validFlagId     = reshape(cat(1,flagObj.Id),size(flag));
    elseif isa(flag,enumerationClassName)
        validFlagId     = reshape(cat(1,flag.Id),size(flag));
    else
        error('Invalid flag datatype.')
    end
end