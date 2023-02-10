function propertyName = validatePropertyName(className,propertyName)

    import DataKit.enum.validateClassName

    assert(ischar(propertyName),...
        'Dingi:DataKit:enum:validatePropertyName:invalidInputType',...
        'Invalid input type ''%s'' for input argument ''propertyName''. The input has to be char.',class(propertyName))

    className           = validateClassName(className);
    classHierarchy      = strsplit(className,'.');
    classTableName      = [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];
    validProperties     = [properties(className);{classTableName}];
    
    if isempty(propertyName)
        propertyName = classTableName;
    end
    
    try
        propertyName        = validatestring(propertyName,validProperties);
    catch ME
        switch ME.identifier
            case 'MATLAB:unrecognizedStringChoice'
                error('Dingi:DataKit:enum:validatePropertyName:invalidPropertyName',...
                    'The property name ''%s'' does not exist for class ''%s''. Valid property names are:\n\t%s\n',propertyName,className,strjoin(validProperties,', '))
            otherwise
                rethrow(ME)
        end
    end
end
