function tbl = info(obj)

    tbl     = table();
    for pool = 1:obj.PoolCount
        tblNew                      = info2table(obj.Info(pool));
        tblNew.Type                	= categorical(tblNew.Type);
        tblNew{:,'IndependantVariableIndex'} = {find(tblNew{:,'Type'} == 'Independant')};
        tblNew{:,'IndependantVariable'} = cellfun(@(iv) obj.Info(pool).Variable(iv),tblNew{:,'IndependantVariableIndex'},'un',0);
        tblNew{:,'DataPoolIndex'}	= pool;
        tbl                         = cat(1,tbl,tblNew(:,[end,1,end - 2,2,end - 1,3:end - 3]));
    end
    tbl{:,'IndependantVariableId'} = cellfun(@(iv) cat(2,iv.Id),tbl{:,'IndependantVariable'},'un',0);
    tbl     = tbl(:,[1:6,end,7:end - 1]);
end