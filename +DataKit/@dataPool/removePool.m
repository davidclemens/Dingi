function obj = removePool(obj,pool)

    if pool > obj.PoolCount
        error('Dingi:DataKit:dataPool:removePool:poolIndexExceedsPoolCount',...
            'The requested data pool index %u exceeds the data pool count of %u.',pool,obj.PoolCount)
    end
    
    obj.DataRaw(pool)     	= [];
    obj.Data(pool)          = [];
    obj.Flag(pool)          = [];
    obj.Uncertainty(pool)	= [];
    obj.Info(pool)          = [];
end