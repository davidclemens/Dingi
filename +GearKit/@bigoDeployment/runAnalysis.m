function runAnalysis(obj)

    import AnalysisKit.bigoFluxAnalysis
    
    relativeTimeUnit	= 'h';
    fitInterval         = [0,4];
    fitType             = 'linear';
    sourceDomains       = {'Ch1','Ch2'};
    nSourceDomains      = numel(sourceDomains);
    
    nObj    = numel(obj);
    
    sourceVolume    = NaN(nObj,nSourceDomains);
    sourceArea      = NaN(nObj,nSourceDomains);
    for oo = 1:nObj
        for src = 1:nSourceDomains
            maskChVolume            = strcmp('volumeViaHeight',{obj(oo).chamber.(sourceDomains{src}).Parameter});
            maskChArea              = strcmp('area',{obj(oo).chamber.(sourceDomains{src}).Parameter});
            sourceVolume(oo,src)    = obj(oo).chamber.(sourceDomains{src})(maskChVolume).Value;
            sourceArea(oo,src)    	= obj(oo).chamber.(sourceDomains{src})(maskChArea).Value;
        end
    end    
   	sourceVolume(oo,isnan(sourceVolume(oo,:))) = nanmean(sourceVolume(:));
    
    for oo = 1:nObj
        [time,fluxParameterData,meta,outlier]	= obj(oo).getData(obj(oo).parameters{:,'ParameterId'},...
                                            'DeploymentDataOnly',	true,...
                                            'RelativeTime',         relativeTimeUnit);
        
        % select only chambers
        [sourceInd,sourceDomainInd] = find(cat(1,meta.dataSourceDomain) == sourceDomains);
        sourceDomainIndex   = NaN(numel(time),1);
        sourceDomainIndex(sourceInd) = sourceDomainInd;
        maskSources         = any(cat(1,meta.dataSourceDomain) == sourceDomains,2);
        time                = time(maskSources);
        fluxParameterData   = fluxParameterData(maskSources,:);
        meta                = meta(maskSources);
        outlier             = outlier(maskSources,:);
        sourceDomainIndex   = sourceDomainIndex(maskSources);
        
        % check if any data is left
        nSources        = numel(time);
        if nSources < 1
            error('Dingi:GearKit:bigoDeployment:runAnalysis',...
                'No requested data found.')
        end
        
        
        obj(oo).analysis	= bigoFluxAnalysis(time,fluxParameterData,meta,...
                                'FitType',              fitType,...
                                'FitInterval',          fitInterval,...
                                'TimeUnit',             relativeTimeUnit,...
                                'FluxVolume',           sourceVolume(oo,sourceDomainIndex)',...
                                'FluxCrossSection',     sourceArea(oo,sourceDomainIndex)',...
                                'Outlier',              outlier);
    end
end