function varargout = subsref(obj,s)

    switch s(1).type
        case '.'
            % Determine if the dot notation is a property access or a method call.
            classInfo = eval(['?',class(obj)]);
            methodList = {classInfo.MethodList.Name}';
            if ismember(s(1).subs,methodList)
                % A class method is called in the dot notation
                varargout = cell(1,nargout);
                [varargout{:}] = builtin('subsref',obj,s);
            else
                % A property is accessed
                varargout = {builtin('subsref',obj,s)};
            end
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
