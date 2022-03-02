function obj = calculateFluxes(obj)
% CALCULATEFLUX

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFluxes:calculatingFluxes',...
        'Info','Calculating fluxes ...')
    
    n       = 100;

    fluxFactorSource        = obj.FluxVolume./obj.FluxCrossSection; % L/m2
    fluxFactorParameter     = 1e-3.*24; % (mmol/µmol) * (h/d)

    statisticalParameters 	= {'Mean',          'Median',           'Perc25',           'Perc75',           'Min',          'Max',          'Std',          'IQR'};
    statisticalFunctions   	= {@(x) nanmean(x), @(x) nanmedian(x),	@(x) prctile(x,25),	@(x) prctile(x,75),	@(x) nanmin(x), @(x) nanmax(x), @(x) nanstd(x), @(x) iqr(x)};
    nStatisticalParameters  = numel(statisticalParameters);

    flux    = NaN(obj.NRates,nStatisticalParameters);
    xq      = obj.TimeUnitFunction(linspace(obj.FitEvaluationInterval(1),obj.FitEvaluationInterval(2),n)');
    fluxes  = NaN(obj.NRates,numel(xq));
    for rr = 1:obj.NRates
        fi = obj.RateIndex(rr);
        
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFluxes:calculatingFlux',...
            'Verbose','%s: Calculating flux for variable %u of %u (%s) ...',obj.Parent.gearId,rr,obj.NRates,obj.FitVariables(fi))

        fluxes(rr,:)	= polyval(polyder(obj.Fits(rr).Coeff),xq); % dUnit/dt
        
        flux(rr,:)      = cellfun(@(func) func(fluxFactorParameter.*fluxFactorSource(fi).*fluxes(rr,:)),statisticalFunctions);
        
        fluxes(rr,:)    = fluxFactorParameter.*fluxFactorSource(fi).*fluxes(rr,:);
    end
    
    obj.Fluxes_        	= fluxes;
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFluxes:calculatingFluxes',...
        'Info','Calculating fluxes ... done')
end
