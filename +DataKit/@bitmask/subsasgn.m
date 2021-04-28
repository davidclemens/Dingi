function obj = subsasgn(obj,s,varargin)
   switch s(1).type
      case '.'
          obj = builtin('subsasgn',obj,s,varargin{:});
      case '()'
         if length(s) == 1
            % Implement obj(indices) = varargin{:};
            obj = obj.setNum(varargin{:},s.subs{:});
         elseif length(s) == 2 && strcmp(s(2).type,'.')
            % Implement obj(indices).PropertyName = varargin{:};
            obj = builtin('subsasgn',obj,s,varargin{:});
         elseif length(s) == 3 && strcmp(s(2).type,'.') && strcmp(s(3).type,'()')
            % Implement obj(indices).PropertyName(indices) = varargin{:};
            obj = builtin('subsasgn',obj,s,varargin{:});
         else
            % Use built-in for any other expression
            obj = builtin('subsasgn',obj,s,varargin{:});
         end       
      case '{}'
          obj = builtin('subsasgn',obj,s,varargin{:});
      otherwise
         error('Not a valid indexing expression')
   end
end