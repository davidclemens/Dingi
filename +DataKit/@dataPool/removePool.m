function varargout = removePool(obj,pool)

    nargoutchk(0,1)
    
    if pool > obj.PoolCount
        error('Dingi:DataKit:dataPool:removePool:poolIndexExceedsPoolCount',...
            'The requested data pool index %u exceeds the data pool count of %u.',pool,obj.PoolCount)
    end
    
    obj.DataRaw(pool)     	= [];
    obj.Data(pool)          = [];
    obj.Flag(pool)          = [];
    obj.Uncertainty(pool)	= [];
    obj.Info(pool)          = [];
    
    obj.IndexNeedsUpdating = true;
    
    if nargout == 1
        varargout{1} = obj;
    end
end