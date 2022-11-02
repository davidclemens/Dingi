function T = createRateTablePerFit(obj)
% createRateTablePerFit  Create rate table per fit
%   CREATERATETABLEPERFIT create a table with one row per fit summarizing all
%   fluxes of an array of bigoFluxAnalyis instances.
%
%   Syntax
%     T = CREATERATETABLEPERFIT(obj)
%
%   Description
%     T = CREATERATETABLEPERFIT(obj)  Creates a table T that summarizies all
%       fluxes of the bigoFluxAnalysis instance(s) obj.
%
%   Example(s)
%     T = CREATERATETABLEPERFIT(analysis)  returns table T.
%
%
%   Input Arguments
%     obj - bigoFluxAnalysis
%       AnalysisKit.bigoFluxAnalysis array
%         An array of bigoFluxAnalyis instances from which the fluxes should be
%         extracted.
%
%
%   Output Arguments
%     T - rates table
%       table
%         The rates table summarizing the fluxes.
%
%
%   Name-Value Pair Arguments
%
%
%   See also ANALYSISKIT.BIGOFLUXANALYSIS.CREATERATETABLEPERDEVICEDOMAIN
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

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
        fitType         = categorical(obj(oo).FitTypes(maskInd)');
        fitR2           = cat(1,obj(oo).Fits.R2);
        fluxes          = obj(oo).Fluxes;

        % Create table
        tbl = table(cruise,gear,areaId,deviceDomains,variables,fluxMean,fluxErrNeg,fluxErrPos,fluxUnit,fitType,fitR2,fluxes,...
            'VariableNames', {'Cruise','Gear','AreaId','DeviceDomain','Variable','FluxMean','FluxErrNeg','FluxErrPos','FluxUnit','FitType','FitR2','Fluxes'});
        
        % Append
        T = cat(1,T,tbl);
    end
end
