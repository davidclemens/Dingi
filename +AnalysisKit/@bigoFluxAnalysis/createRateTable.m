function createRateTable(obj)
    
    maskInd         = obj.RateIndex;
    nRows           = numel(maskInd);
    cruise          = repmat(obj.Parent.cruise,nRows,1);
    gear            = repmat(obj.Parent.gear,nRows,1);
    areaId          = repmat(obj.Parent.areaId,nRows,1);
    deviceDomains	= obj.FitDeviceDomains(maskInd);
    variables       = obj.FitVariables(maskInd);
    fluxMean        = obj.FluxStatistics(:,1);
    fluxErrPos      = obj.FluxStatistics(:,3) - fluxMean;
    fluxErrNeg      = obj.FluxStatistics(:,4) - fluxMean;
    fluxUnit        = repmat(categorical({['mmol m⁻² ',obj.TimeUnit,'⁻¹']}),nRows,1);

    obj.Rates_ = table(cruise,gear,areaId,deviceDomains,variables,fluxMean,fluxErrPos,fluxErrNeg,fluxUnit,...
        'VariableNames', {'Cruise','Gear','AreaId','DeviceDomain','Variable','FluxMean','FluxErrPos','FluxErrNeg','FluxUnit'});
end