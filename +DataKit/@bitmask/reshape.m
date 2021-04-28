function obj = reshape(obj,varargin)

    obj = DataKit.bitmask(reshape(obj.Bits,varargin{:}));
end