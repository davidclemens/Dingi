function tbl = getFlux(obj,parameter)
% GETFLUX

    nObj    = numel(obj);
    
    tbl     = table();
    for oo = 1:nObj
        newTable                = obj(oo).analysis.getFlux(parameter);
        newTableVarNames        = newTable.Properties.VariableNames;
        newTable{:,'Cruise'}    = obj(oo).cruise;
        newTable{:,'Gear'}      = obj(oo).gear;
        newTable{:,'AreaId'}    = obj(oo).areaId;
        
        tbl	= [tbl;newTable(:,[{'Cruise','Gear'},newTableVarNames,{'AreaId'}])];
    end
end