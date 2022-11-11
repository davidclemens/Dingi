function varargout = size(obj,varargin)

    narginchk(1,2)
    
    nDims   = ndims(obj.Bits);
    
    sz = size(obj.Bits,varargin{:});
    
    if nargout <= 1
        varargout{1} = sz;
    elseif nargout >= 2
        if nargout < nDims
            varargout = num2cell([sz(1:nargout - 1),prod(sz(nargout:end))]);
        else
            varargout = num2cell([sz,ones(1,nargout - nDims)]);
        end
    end
end
