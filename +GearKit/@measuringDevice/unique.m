function [C,ia,ic] = unique(A,varargin)

    A   = A(:);
    
    uStr = strcat(cellstr(cat(1,A.Type)),reshape({A.SerialNumber},[],1));
    
    [~,ia,ic] = unique(uStr,varargin{:});
    C   = A(ia);
end