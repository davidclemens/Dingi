function [tf,ind] = isValidPropertyValue(className,propertyName,propertyValues)

    import DataKit.enum.validateClassName
    import DataKit.enum.validatePropertyName
    import DataKit.enum.listValidPropertyValues


    className           = validateClassName(className);
    classHierarchy      = strsplit(className,'.');
    classTableName      = [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
    propertyName    	= validatePropertyName(className,propertyName);
    
    propertyValueClass  = class(propertyValues);
    if ischar(propertyValues)
        propertyValues  = cellstr(propertyValues);
    end
    szValues            = size(propertyValues);
    propertyValues      = reshape(propertyValues,[],1);
    
    enumerationMembers	= enumeration(className);
    enumerationMember 	= enumerationMembers(end);
    
    % Get valid property values
    validPropertyValues = listValidPropertyValues(className,propertyName);
    
    if strcmp(propertyName,classTableName)
        propertyClass	= className;
        
        % Get valid property strings for error messages
        validPropertyValuesStr = strjoin(cellstr(enumerationMembers),', ');
    else
        propertyClass	= class(enumerationMember.(propertyName));
        
        % Get valid property strings for error messages
        if isnumeric(enumerationMember.(propertyName))
            validPropertyValuesStr  = mat2str(unique(validPropertyValues));
        elseif ischar(enumerationMember.(propertyName))
            validPropertyValuesStr  = strjoin(unique(validPropertyValues),', ');
        end
    end
    
    if strcmp('char',propertyClass)
        if ~iscellstr(propertyValues)
            error('Dingi:DataKit:enum:isValidPropertyValue:invalidPropertyValueType',...
                'The property value type for property ''%s'' of class ''%s'' should be ''cellstr'' or ''char''. It was ''%s'' instead.',propertyName,className,class(propertyValues))
        end        
        
        % If the property is a char, do fuzzy matching and return as cellstr
        nPropertyValues  	= numel(propertyValues);
        newPropertyValues 	= repmat({'[]'},1,nPropertyValues);
        for vv = 1:nPropertyValues     
            try
                newPropertyValues{vv}	= validatestring(propertyValues{vv},validPropertyValues);
            catch ME
                switch ME.identifier
                    case 'MATLAB:ambiguousStringChoice'
                    case 'MATLAB:unrecognizedStringChoice'
                    otherwise
                        rethrow(ME);
                end
            end
        end
    elseif strcmp(className,propertyClass)
        if ~iscellstr(propertyValues)
            error('Dingi:DataKit:enum:isValidPropertyValue:invalidPropertyValueType',...
                'The property value type for property ''%s'' of class ''%s'' should be ''cellstr'' or ''char''. It was ''%s'' instead.',propertyName,className,class(propertyValues))
        end        
        
        % If the property is the same as the enum class, do fuzzy matching
        % and return as the enum class
        nPropertyValues  	= numel(propertyValues);
        newPropertyValues 	= repmat({'[]'},1,nPropertyValues);
        validPropertyValues = cellstr(validPropertyValues);
        for vv = 1:nPropertyValues     
            try
                newPropertyValues{vv}	= validatestring(propertyValues{vv},validPropertyValues);
            catch ME
                switch ME.identifier
                    case 'MATLAB:ambiguousStringChoice'
                    case 'MATLAB:unrecognizedStringChoice'
                    otherwise
                        rethrow(ME);
                end
            end
        end
    elseif isnumeric(enumerationMember.(propertyName))
        if ~isnumeric(propertyValues)
            error('Dingi:DataKit:enum:isValidPropertyValue:invalidPropertyValueType',...
                'The property value type for property ''%s'' of class ''%s'' should be numeric. It was ''%s'' instead.',propertyName,className,class(propertyValues))
        end   
        try
            newPropertyValues	= propertyValues;
        catch ME
            error('Dingi:DataKit:enum:isValidPropertyValue:invalidPropertyValueType',...
                'Invalid property value type ''%s''. Values for property ''%s'' of class ''%s'' have to be of type ''%s''.',propertyValueClass,propertyName,className,propertyClass)
        end
    else
        error('Dingi:DataKit:enum:isValidPropertyValue:TODO',...
            'TODO: not implemented yet.')
    end
    
    [tf,ind]    = ismember(newPropertyValues,validPropertyValues);
    tf          = reshape(tf,szValues);
    ind         = reshape(ind,szValues);
end