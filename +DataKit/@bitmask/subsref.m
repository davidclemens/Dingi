function varargout = subsref(obj,s)

    switch s(1).type
        case '.'
            varargout = {builtin('subsref',obj,s)};
        case '()'
            if length(s) == 1
                % Implement obj(indices)
                varargout = {DataKit.bitmask(obj.Bits(s.subs{:}))};
            else
                % Use built-in for any other expression
                varargout = {builtin('subsref',obj,s)};
            end
        case '{}'
            varargout = {builtin('subsref',obj,s)};
        otherwise
            error('Dingi:DataKit:Metadata:sparseBitmask:subsref:invalidIndexingExpression',...
              'Not a valid indexing expression')
    end
end
