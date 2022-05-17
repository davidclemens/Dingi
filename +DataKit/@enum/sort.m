function varargout = sort(obj,varargin)
    
    import DataKit.enum.cell2enum
    
    objClass    = class(obj);
    [B,I]       = sort(string(cellstr(obj)),varargin{:});
    objS        = cell2enum(B,objClass);
    
    varargout{1}    = objS;
    varargout{2}    = I;
end