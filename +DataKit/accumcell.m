function A = accumcell(subs,val,varargin)

    nrhs    = nargin;
    if nrhs == 3
        sz      = varargin{1};
        func    = @(x) {x};
        fillval = {[]};
    elseif nrhs == 4
        sz      = varargin{1};
        func    = varargin{2};
        fillval = {[]};
    elseif nrhs == 5
        sz      = varargin{1};
        func    = varargin{2};
        fillval = varargin{3};
    end
    
    A           = cell(sz);
    [u,~,uIdx]  = unique(subs,'rows');
    uAsCell     = num2cell(u,1);
    uInd        = sub2ind(sz,uAsCell{:});
    nU          = size(u,1);
    for e = 1:nU
        mask    	= uIdx == e;
%         try
        A(uInd(e)) 	= {func(val(mask))};
%         catch
%             
%         end
    end
    
    maskFill    = setdiff(1:prod(sz),uInd);
    A(maskFill) = fillval;
end