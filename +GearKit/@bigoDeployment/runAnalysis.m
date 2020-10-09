function obj = runAnalysis(obj)

    import AnalysisKit.bigoFluxAnalysis
    
    nObj    = numel(obj);
    for oo = 1:nObj
        % sensor data
        [time,fluxParameter,meta] 	= obj(oo).getData({'oxygen','temperature','conductivity','lightIntensity'},...
                                        'DeploymentDataOnly',	true,...
                                        'RelativeTime',         'h');
        % analytical data
        
                                    
        obj(oo).analysis            = bigoFluxAnalysis(time,fluxParameter);
    end
end