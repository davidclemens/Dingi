function varargout = subsref(obj,S)
    switch S(1).type
        case '.'
            % Determine if the dot notation is a property access or a method call.
            classInfo = eval(['?',class(obj)]);
            methodList = {classInfo.MethodList.Name}';
            if ismember(S(1).subs,methodList)
                % A class method is called in the dot notation
                varargout = cell(1,nargout);
                [varargout{:}] = builtin('subsref',obj,S);
            else
                % A property is accessed
                varargout = {builtin('subsref',obj,S)};
            end
        case '()'
            if numel(S) == 1 && numel(S.subs) == 1 && ischar(S.subs{1})
                % Implement value = obj('key')                
                varargout = {obj.Catalog(S.subs{1})};
            else
                varargout = {builtin('subsref',obj,S)};
            end
        case '{}'
            varargout = {builtin('subsref',obj,S)};
        otherwise
            error('Dingi:DataKit:Units:unitCatalog:subsref:InvalidIndexingExpression',...
                'Not a valid indexing expression')
    end
end
