function tbl = info(obj)

    tbl     = table();
    for pool = 1:obj.PoolCount
        tblNew                  = info2table(obj.Info(pool));
        tblNew{:,'DataPoolIndex'}	= pool;
        tbl                     = cat(1,tbl,tblNew(:,[end,1:end - 1]));
    end
    
    tbl.Type                    = categorical(tbl.Type);
end