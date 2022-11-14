function obj = subsasgn(obj,S,varargin)
    switch S(1).type
        case '()'
            if numel(S) == 1
            % Implement obj(indices) = varargin{:};
                A = subsasgn(double(obj),S,double(varargin{1}));
                dA = subsasgn(obj.StDev,S,varargin{1}.StDev);
                % TODO: Implement subsasgn for DataKit.bitflag
                flag = subsasgn(obj.Flag,S,varargin{1}.Flag.Bits);
                obj = DataKit.quantity(A,dA,flag);
            else
                obj = subsasgn@double(subsref(obj,S(1)),S(2:end),varargin{:});
            end
        otherwise
            obj = subsasgn@double(obj,S,varargin{:});
    end
end