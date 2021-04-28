function className = validateClassName(className)

    if ~ischar(className)
        error('Dingi:DataKit:enum:validateClassName:invalidInputType',...
            'Invalid input type ''%s'' for input argument ''className''. The input has to be char.',class(className))
    end

    infoDingi       = what('Dingi');
    pathDingi       = infoDingi.path;
    enumSubclasses	= getSubclasses('DataKit.enum',pathDingi);
    validClassNames = {enumSubclasses.Class}';
            
    try
        className        = validatestring(className,validClassNames);
    catch ME
        switch ME.identifier
            case 'MATLAB:unrecognizedStringChoice'
                error('Dingi:DataKit:enum:validateClassName:invalidClassName',...
                    'The enumeration class name ''%s'' does not exist. Valid enumeration class names are:\n\t%s\n',className,strjoin(validClassNames,'\n\t'))
            otherwise
                rethrow(ME)
        end
    end
end