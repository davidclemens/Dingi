function obj = reshape(obj,varargin)

    obj = DataKit.bitflag(obj.EnumerationClassName,reshape(obj.Bits,varargin{:}));
end