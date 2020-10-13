function obj = runAnalysis(obj)

    import AnalysisKit.bigoFluxAnalysis
    
    relativeTimeUnit	= 'h';
    fitInterval         = [0,4];
    fitType             = 'linear';
    
    nObj    = numel(obj);
    for oo = 1:nObj
        [time,fluxParameterData,meta]	= obj(oo).getData(obj(oo).parameters{:,'ParameterId'},...
                                            'DeploymentDataOnly',	true,...
                                            'RelativeTime',         relativeTimeUnit);
        
        % select only chambers
        maskSources         = any(cat(1,meta.dataSourceDomain) == {'Ch1','Ch2'},2);
        time                = time(maskSources);
        fluxParameterData   = fluxParameterData(maskSources,:);
        meta                = meta(maskSources);
        
        % check if any data is left
        nSources        = numel(time);
        if nSources < 1
            error('GearKit:bigoDeployment:runAnalysis',...
                'No requested data found.')
        end
        
        sourceVolume    = NaN(nSources,1);
        sourceArea      = NaN(nSources,1);
        for src = 1:nSources
            maskChVolume        = strcmp('volumeViaHeight',{obj(oo).chamber.(char(meta(src).dataSourceDomain)).Parameter});
            maskChArea          = strcmp('area',{obj(oo).chamber.(char(meta(src).dataSourceDomain)).Parameter});
            sourceVolume(src)   = obj(oo).chamber.(char(meta(src).dataSourceDomain))(maskChVolume).Value;
            sourceArea(src)     = obj(oo).chamber.(char(meta(src).dataSourceDomain))(maskChArea).Value;
        end
        
        obj(oo).analysis	= bigoFluxAnalysis(time,fluxParameterData,meta,...
                                'FitType',              fitType,...
                                'FitInterval',          fitInterval,...
                                'TimeUnit',             relativeTimeUnit,...
                                'FluxVolume',           sourceVolume,...
                                'FluxCrossSection',     sourceArea);
    end
end