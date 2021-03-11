function [tf,info] = core_validate(className,propertyName,propertyValues)

    import DataKit.enum.validateClassName
    import DataKit.enum.validatePropertyName
    import DataKit.enum.isValidPropertyValue
    import DataKit.enum.listValidPropertyValues
    import DataKit.enum.core_listMembersInfo
    import DataKit.table2emptyRow
    
    
    className           = validateClassName(className);
    propertyName    	= validatePropertyName(className,propertyName);
    
    if ischar(propertyValues)
        propertyValues = cellstr(propertyValues);
    end
    szValue             = size(propertyValues);
    propertyValues      = reshape(propertyValues,[],1);
    
    enumerationMemberInfo 	= core_listMembersInfo(className);    
    
    [tf,ind]        = isValidPropertyValue(className,propertyName,propertyValues);
    
    infoEmptyRow    = table2emptyRow(enumerationMemberInfo);
    info(tf,:)      = enumerationMemberInfo(ind(tf),:);
    info(~tf,:)   	= repmat(infoEmptyRow,sum(~tf),1);
    
    tf      = reshape(tf,szValue);
    info    = reshape(table2struct(info),szValue);
end