function varargout = subsref(obj,S)

    switch S(1).type
        case '.'
            varargout = {builtin('subsref',obj,S)};
        case '()'
            if length(S) == 1
                % Implement obj(indices)
                varargout = {DataKit.bitflag(obj.EnumerationClassName,obj.Bits(S.subs{:}))};
            else
                % Use built-in for any other expression
                varargout = {builtin('subsref',obj,S)};
            end
        case '{}'
            varargout = {builtin('subsref',obj,S)};
        otherwise
            error('Dingi:DataKit:bitflag:subsref:invalidIndexingExpression',...
              'Not a valid indexing expression')
    end
end
