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
        maskInd             = obj(oo).RateIndex;
        nRows               = numel(maskInd);
        isRelevantSample  	= isFlag(obj(oo).FlagData(:,maskInd),{'IsSample'}) & ~isFlag(obj(oo).FlagData(:,maskInd),{'IsNotInFitInterval'});
        
        
        cruise              = repmat(obj(oo).Parent.cruise,nRows,1);
        cruiseDsc           = 'Cruise Id of the flux''s gear deployment';
        gear                = repmat(obj(oo).Parent.gear,nRows,1);
        gearDsc             = 'Gear Id of the flux''s gear deployment';
        areaId              = repmat(obj(oo).Parent.areaId,nRows,1);
        areaIdDsc           = 'Area Id of the flux''s gear deployment';
        deviceDomains	    = obj(oo).FitDeviceDomains(maskInd);
        deviceDomainsDsc    = 'Device domain of the fluxes';
        variables           = obj(oo).FitVariables(maskInd);
        variablesDsc        = 'Variable name of the fluxes';
        fluxVolume          = obj(oo).FluxVolume(maskInd);
        fluxVolumeDsc       = 'The chamber volume (L) used for the flux calculation';
        fluxMean            = round(obj(oo).FluxStatistics(:,1),4,'significant');
        fluxMeanDsc         = 'The mean flux of the fluxes derived from the fit within the fit evaluation interval [see ''FitEvaluationInterval'']';
        fluxErrNeg          = round(obj(oo).FluxStatistics(:,3) - fluxMean,4,'significant');
        fluxErrNegDsc       = 'The absolute difference of the 25th percentile to the mean flux of the fluxes derived from the fit within the fit evaluation interval [see ''FitEvaluationInterval'']';
        fluxErrPos          = round(obj(oo).FluxStatistics(:,4) - fluxMean,4,'significant');
        fluxErrPosDsc       = 'The absolute difference of the 75th percentile to the mean flux of the fluxes derived from the fit within the fit evaluation interval [see ''FitEvaluationInterval'']';
        fluxUnit            = repmat(categorical({['mmol m⁻² ',obj(oo).TimeUnit,'⁻¹']}),nRows,1);
        fluxUnitDsc         = 'Unit of the fluxes';
        fitType             = categorical(obj(oo).FitTypes(maskInd));
        fitTypeDsc          = 'Fit type of the fluxes';
        fitFlags            = reshape(obj(oo).FlagDataset(maskInd),[],1);
        fitFlagsDsc         = 'Fit flags that have been set';
        fitR2               = round(cat(1,obj(oo).Fits.R2),4,'significant');
        fitR2Dsc            = 'R² value of the fit of the flux';
        fitNExcluded        = sum(isRelevantSample & obj(oo).Exclude(:,maskInd));
        fitNExcludedDsc     = 'Number of samples of the total number of samples that are excluded from the fit';
        fitNTotal           = sum(isRelevantSample);
        fitNTotalDsc        = 'Total number of samples that available for the fit';
        fitEvalInt          = repmat(obj(oo).FitEvaluationInterval,nRows,1);
        fitEvalIntDsc       = 'The incubation interval within which the fits are evaluated to calculate the flux mean & errors';
        fluxes              = obj(oo).Fluxes;
        fluxesDsc           = '';

        % Correct errors for linear fits
        isLinearFit = fitType == 'linear';
        fluxErrNeg(isLinearFit) = 0;
        fluxErrPos(isLinearFit) = 0;
        
        % Create table
        tbl = table(cruise,gear,areaId,deviceDomains,variables,fluxVolume,fluxMean,fluxErrNeg,fluxErrPos,fluxUnit,fitType,fitFlags,fitR2,fitNExcluded',fitNTotal',fitEvalInt,fluxes,...
            'VariableNames', ...
            {'Cruise','Gear','AreaId','DeviceDomain','Variable','Volume','FluxMean','FluxErrNeg','FluxErrPos','FluxUnit','FitType','FitFlags','FitR2','FitNExcluded','FitNTotal','FitEvaluationInterval','Fluxes'});
        tbl.Properties.VariableDescriptions = ...
            {cruiseDsc,gearDsc,areaIdDsc,deviceDomainsDsc,variablesDsc,fluxVolumeDsc,fluxMeanDsc,fluxErrNegDsc,fluxErrPosDsc,fluxUnitDsc,fitTypeDsc,fitFlagsDsc,fitR2Dsc,fitNExcludedDsc,fitNTotalDsc,fitEvalIntDsc,fluxesDsc};
        
        % Append
        T = cat(1,T,tbl);
    end
end
