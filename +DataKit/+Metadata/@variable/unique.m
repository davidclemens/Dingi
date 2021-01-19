function varargout = unique(obj,varargin)

    sz      = size(obj);
    name    = cellstr(obj);
    id      = reshape(cellstr(num2str(cat(1,obj.Id),'%03u')),sz);
    A       = strcat(name,id);
    
    [C,ia,ic] = unique(A,varargin{:});
    
    varargout{1} = C;
    varargout{2} = ia;
    varargout{3} = ic;    
end