function obj = runAnalysis(obj)
% RUNANALYSIS

    import AnalysisKit.eddyFluxAnalysis
    
    nObj    = numel(obj);
    for oo = 1:nObj
        
        [time,data,meta]     = obj(oo).getData({'velocityU','velocityV','velocityW','oxygen'},...
                                    'SensorId',             'NortekVector',...
                                    'DeploymentDataOnly',	true);
        time            = time{1};
        velocity        = cat(2,data{1:3});
        fluxParameter   = data{4};

        obj(oo).analysis	= eddyFluxAnalysis(time,velocity,fluxParameter);
    end
end