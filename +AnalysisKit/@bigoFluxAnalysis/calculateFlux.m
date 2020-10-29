function obj = calculateFlux(obj)
% CALCULATEFLUX
    
    n       = 100;
    
    fluxFactorSource        = obj.fluxVolume./obj.fluxCrossSection; % L/m2
    fluxFactorParameter     = 1e-3.*24.*ones(1,numel(obj.fluxParameterUnit)); % (mmol/µmol) * (h/d)
    
    statisticalParameters 	= {'Mean',          'Median',           'Perc25',           'Perc75',           'Min',          'Max',          'Std',          'IQR'};
    statisticalFunctions   	= {@(x) nanmean(x), @(x) nanmedian(x),	@(x) prctile(x,25),	@(x) prctile(x,75),	@(x) nanmin(x), @(x) nanmax(x), @(x) nanstd(x), @(x) iqr(x)};
    nStatisticalParameters  = numel(statisticalParameters);
    
    flux    = NaN(obj.nFits,nStatisticalParameters);
    xq      = linspace(obj.fitInterval(1),obj.fitInterval(2),n)';
    fluxes  = NaN(obj.nFits,numel(xq));
    confidenceInterval = NaN(obj.nFits,2);
    for ff = 1:obj.nFits
        fluxes(ff,:)	= differentiate(obj.fitObjects{ff},xq); % dUnit/dt
        
        flux(ff,:)      = cellfun(@(func) func(fluxFactorParameter(obj.indParameter(ff)).*fluxFactorSource(obj.indSource(ff)).*fluxes(ff,:)),statisticalFunctions);
        
        switch obj.fitType
            case 'linear'
                tmp = confint(obj.fitObjects{ff},0.68);
                confidenceInterval(ff,:) = tmp(:,2)'.*fluxFactorParameter(obj.indParameter(ff)).*fluxFactorSource(obj.indSource(ff));
            otherwise
                error('not impl')
        end
    end
    obj.flux            = fluxes;
    obj.fluxConfInt     = confidenceInterval;
    obj.fluxStatistics  = flux;
end