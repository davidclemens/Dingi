function obj = calculateFluxes(obj)
% CALCULATEFLUX

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Info','%s: Calculating fluxes for %u variable(s) ...',obj.Parent.gearId,obj.NFits)
    
    n       = 100;

    fluxFactorSource        = obj.FluxVolume./obj.FluxCrossSection; % L/m2
    fluxFactorParameter     = 1e-3.*24; % (mmol/µmol) * (h/d)

    statisticalParameters 	= {'Mean',          'Median',           'Perc25',           'Perc75',           'Min',          'Max',          'Std',          'IQR'};
    statisticalFunctions   	= {@(x) nanmean(x), @(x) nanmedian(x),	@(x) prctile(x,25),	@(x) prctile(x,75),	@(x) nanmin(x), @(x) nanmax(x), @(x) nanstd(x), @(x) iqr(x)};
    nStatisticalParameters  = numel(statisticalParameters);

    flux    = NaN(obj.NFits,nStatisticalParameters);
    xq      = obj.TimeUnitFunction(linspace(obj.FitEvaluationInterval(1),obj.FitEvaluationInterval(2),n)');
    fluxes  = NaN(obj.NFits,numel(xq));
    confidenceInterval = NaN(obj.NFits,2);
    for ff = 1:obj.NFits
        printDebugMessage('Verbose','%s: Calculating flux for variable %u of %u (%s) ...',obj.Parent.gearId,ff,obj.NFits,obj.FitVariables(ff))
        if isempty(obj.FitObjects{ff})
            printDebugMessage('Verbose','%s: Calculating flux for variable %u of %u (%s) ... no fit found',obj.Parent.gearId,ff,obj.NFits,obj.FitVariables(ff))
            continue
        end
        fluxes(ff,:)	= differentiate(obj.FitObjects{ff},xq); % dUnit/dt

        flux(ff,:)      = cellfun(@(func) func(fluxFactorParameter.*fluxFactorSource(ff).*fluxes(ff,:)),statisticalFunctions);
        
        fluxes(ff,:)    = fluxFactorParameter.*fluxFactorSource(ff).*fluxes(ff,:);
        switch obj.FitType
            case 'linear'
                tmp = confint(obj.FitObjects{ff},0.68);
                confidenceInterval(ff,:) = fluxFactorParameter.*fluxFactorSource(ff).*tmp(:,2)';
            case 'sigmoidal'
%                 tmp = confint(obj.FitObjects{ff},0.68);
%                 confidenceInterval(ff,:) = fluxFactorParameter.*fluxFactorSource(ff).*tmp(:,2)';
            case 'polynomial4'
                
            otherwise
                error('Dingi:AnalysisKit:bigoFluxAnalysis:calculateFlux:TODO',...
                  'TODO: ''%s'' is not implemented yet.',obj.FitType)
        end
    end
    
    obj.Flux            = fluxes;
    obj.FluxConfInt     = confidenceInterval;
    obj.FluxStatistics  = flux;
    
    printDebugMessage('Info','%s: Calculating fluxes for %u variable(s) ... done',obj.Parent.gearId,obj.NFits)
end
