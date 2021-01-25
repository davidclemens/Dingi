function [tf,info] = core_validate(classname,propertyName,value)

    import DataKit.enum.core_listMembersInfo
    import DataKit.table2emptyRow
    
    
    classHierarchy      = strsplit(classname,'.');
    classTableName      = [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
    validProperties     = [properties(classname);{classTableName}];
    memberInfo        	= core_listMembersInfo(classname);
    
    if isempty(propertyName)
        propertyName = classTableName;
    end
    
    if isempty(validProperties)
        error('Dingi:DataKit:enum:core_validate:noAttributesAvailable',...
            'There are no attributes defined for class ''%s''.',classname)
    end
    propertyName        = validatestring(propertyName,validProperties);
    propertyClass       = class(memberInfo{:,propertyName});
    
    membersAreUnique    = numel(unique(memberInfo{:,propertyName})) == numel(memberInfo{:,propertyName});
    if ~membersAreUnique
        error('Dingi:DataKit:enum:core_validate:nonUniqueMembers',...
            'The values for property ''%s'' are not unique.',propertyName)
    end
    
    if ischar(value)
        value = cellstr(value);
    end
    
    try
        [tf,imIdx]      = ismember(value,memberInfo{:,propertyName});
    catch ME
        switch ME.identifier
            case 'MATLAB:ISMEMBER:InputClass'
                error('Dingi:DataKit:enum:core_validate:incompatibleClasses',...
                    'The class of the input ''value'' is incompatable with the class of the property ''%s'' (%s).',propertyName,propertyClass)
            otherwise
                rethrow(ME)
        end
    end
    infoEmptyRow    = table2emptyRow(memberInfo);
    info(tf,:)      = memberInfo(imIdx(tf),:);
    info(~tf,:)   	= repmat(infoEmptyRow,sum(~tf),1);
end