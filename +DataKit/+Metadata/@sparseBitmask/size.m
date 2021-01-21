function varargout = size(obj,varargin)  
    
    narginchk(1,2)
    
    if nargin == 1
        if nargout <= 1
            varargout	= {size(obj.Bitmask,varargin{:})};
        elseif nargout > 1
            varargout = cell(1,nargout);
            for ii = 1:nargout
                varargout{ii} = size(obj.Bitmask,ii);
            end
        end
    else
        nargoutchk(0,1)
    	varargout	= {size(obj.Bitmask,varargin{:})};
    end
end