function obj = subsasgn(obj,S,varargin)

    switch S(1).type
        case '.'
            obj = builtin('subsasgn',obj,S,varargin{:});
        case '()'
            if length(S) == 1
                % Implement obj(indices) = varargin{:};
             	obj = obj.setNum(varargin{:},S.subs{:});
            else
                % Use built-in for any other expression
                obj = builtin('subsasgn',obj,S,varargin{:});
            end       
        case '{}'
            obj = builtin('subsasgn',obj,S,varargin{:});
        otherwise
            error('Dingi:DataKit:bitflag:subsasgn:invalidIndexingExpression',...
              'Not a valid indexing expression')
    end
end
