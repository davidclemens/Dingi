function className = validateClassName(className)

    % Test that the class is valid
    try
        assert(~isempty(meta.class.fromName(className)),...
            'Dingi:DataKit:enum:validateClassName:InvalidClassName',...
            'The enumeration class name ''%s'' doesn''t exist.',className)
    catch ME
        switch ME.identifier
            case 'MATLAB:class:RequireString'
                error('Dingi:DataKit:enum:validateClassName:invalidInputType',...
                    'Invalid input type ''%s'' for input argument ''className''. The input has to be char.',class(className))
            otherwise
                rethrow(ME)
        end
    end
end
