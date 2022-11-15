function obj = subsasgn(obj,S,varargin)
    switch S(1).type
        case '()'
            if numel(S) == 1
            % Implement obj(indices) = varargin{:};
                A       = subsasgn(double(obj),S,double(varargin{1}));
                sigma   = subsasgn(obj.Sigma,S,varargin{1}.Sigma);
                flag    = subsasgn(obj.Flag,S,varargin{1}.Flag.Bits);
                obj     = DataKit.quantity(A,sigma,flag);
            else
                obj = subsasgn@double(subsref(obj,S(1)),S(2:end),varargin{:});
            end
        otherwise
            obj = subsasgn@double(obj,S,varargin{:});
    end
end
