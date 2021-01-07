function varargout = subsref(obj,s)

    switch s(1).type
        case '.'
%             if length(s) == 1
%                 % Implement obj.PropertyName
%                 ...
%             elseif length(s) == 2 && strcmp(s(2).type,'()')
%                 % Implement obj.PropertyName(indices)
%                 ...
%             else
%                 varargout = {builtin('subsref',obj,s)};
%             end
            varargout = {builtin('subsref',obj,s)};
        case '()'
            if length(s) == 1
                % Implement obj(indices)
                varargout = {DataKit.Metadata.dataFlag(obj.Bitmask(s.subs{:}))};
%             elseif length(s) == 2 && strcmp(s(2).type,'.')
%                 % Implement obj(ind).PropertyName
%                 ...
%             elseif length(s) == 3 && strcmp(s(2).type,'.') && strcmp(s(3).type,'()')
%                 % Implement obj(indices).PropertyName(indices)
%                 ...
            else
                % Use built-in for any other expression
                varargout = {builtin('subsref',obj,s)};
            end
        case '{}'
%             if length(s) == 1
%                 % Implement obj{indices}
%                 ...
%             elseif length(s) == 2 && strcmp(s(2).type,'.')
%                 % Implement obj{indices}.PropertyName
%                 ...
%             else
%                 % Use built-in for any other expression
%                 varargout = {builtin('subsref',obj,s)};
%             end
            varargout = {builtin('subsref',obj,s)};
        otherwise
            error('Not a valid indexing expression')
    end
end