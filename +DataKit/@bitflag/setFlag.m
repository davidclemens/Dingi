function obj = setFlag(obj,flag,highlow,varargin)

    import DataKit.bitflag.validateFlag
    
    % Check number of input arguments
    narginchk(5,inf)
    
    flagId = validateFlag(obj.EnumerationClassName,flag);
    
    obj = obj.setBit(flagId,highlow,varargin{:});
end