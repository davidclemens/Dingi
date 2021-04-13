function varargout = setFlag(obj,poolIdx,i,j,flag,highlow)

    import DataKit.arrayhom
    
    nargoutchk(0,1)
    
    if ~isscalar(obj)
        error('Dingi:DataKit:dataPool:setFlag:onlyScalarContextAllowed',...
            'Only works in a scalar context.')
    end
    
    [poolIdx,i,j,flag,highlow] = arrayhom(poolIdx,i,j,flag,highlow);
    
    uPool	= unique(poolIdx);
    nuPool 	= numel(uPool);
    
    for p = 1:nuPool
        pool    = uPool(p);
        mask    = poolIdx == pool;
        
        obj.Flag{pool} =  setBit(obj.Flag{pool},i(mask),j(mask),flag(mask),highlow(mask));
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end