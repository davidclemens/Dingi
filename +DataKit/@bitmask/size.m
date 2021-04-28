function varargout = size(obj,varargin)

    narginchk(1,2)
    
    nDims   = ndims(obj.Bits);
    nargoutchk(0,nDims)
    
    if numel(varargin) == 0
        sz = cell(1,nDims);
    else
        sz = cell(1);
    end
    [sz{:}] = size(obj.Bits,varargin{:});
    
    varargout = sz;
end