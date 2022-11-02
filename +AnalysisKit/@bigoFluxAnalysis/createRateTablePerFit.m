function T = createRateTablePerFit(obj)
    
    % Get number of instances
    nObj = numel(obj);
    
    % Initialize
    T = table();
    
    % Loop over instances
    for oo = 1:nObj
        maskInd         = obj(oo).RateIndex;
        nRows           = numel(maskInd);
        cruise          = repmat(obj(oo).Parent.cruise,nRows,1);
        gear            = repmat(obj(oo).Parent.gear,nRows,1);
        areaId          = repmat(obj(oo).Parent.areaId,nRows,1);
        deviceDomains	= obj(oo).FitDeviceDomains(maskInd);
        variables       = obj(oo).FitVariables(maskInd);
        fluxMean        = obj(oo).FluxStatistics(:,1);
        fluxErrNeg      = obj(oo).FluxStatistics(:,3) - fluxMean;
        fluxErrPos      = obj(oo).FluxStatistics(:,4) - fluxMean;
        fluxUnit        = repmat(categorical({['mmol m⁻² ',obj(oo).TimeUnit,'⁻¹']}),nRows,1);
        fitR2           = cat(1,obj(oo).Fits.R2);
        fluxes          = obj(oo).Fluxes;

        % Create table
        tbl = table(cruise,gear,areaId,deviceDomains,variables,fluxMean,fluxErrNeg,fluxErrPos,fluxUnit,fitR2,fluxes,...
            'VariableNames', {'Cruise','Gear','AreaId','DeviceDomain','Variable','FluxMean','FluxErrNeg','FluxErrPos','FluxUnit','FitR2','Fluxes'});
        
        % Append
        T = cat(1,T,tbl);
    end
end
