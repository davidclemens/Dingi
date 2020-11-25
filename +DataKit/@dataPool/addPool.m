function obj = addPool(obj)

    pool                    = obj.PoolCount + 1;
    obj.DataRaw(pool)     	= {NaN(0,0)};
    obj.Flag(pool)          = {zeros(0,0,'uint32')};
    obj.Uncertainty(pool)	= {sparse(zeros(0,0))};
    obj.Info(pool)          = DataKit.Metadata.info;
    
    obj	= update(obj);
end