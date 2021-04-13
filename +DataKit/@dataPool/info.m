function tbl = info(obj)

    tbl     = table();
    for pool = 1:obj.PoolCount
        tblNew                      = info2table(obj.Info(pool));
        tblNew.Type                	= categorical(tblNew.Type);
        tblNew{:,'IndependentVariableIndex'} = {find(tblNew{:,'Type'} == 'Independent')};
        tblNew{:,'IndependentVariable'} = cellfun(@(iv) obj.Info(pool).Variable(iv),tblNew{:,'IndependentVariableIndex'},'un',0);
        tblNew{:,'DataPoolIndex'}	= pool;
        tbl                         = cat(1,tbl,tblNew(:,[end,1,end - 2,2,end - 1,3:end - 3]));
    end
    tbl{:,'IndependentVariableId'} = cellfun(@(iv) cat(2,iv.Id),tbl{:,'IndependentVariable'},'un',0);
    tbl     = tbl(:,[1:6,end,7:end - 1]);
end