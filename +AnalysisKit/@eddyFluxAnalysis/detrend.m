function varargout = detrend(obj,varargin)
% DETREND

	import internal.stats.parseArgs
    import AnalysisKit.eddyFluxAnalysis.detrendMeanRemoval
    import AnalysisKit.eddyFluxAnalysis.detrendLinear
    import AnalysisKit.eddyFluxAnalysis.detrendMovingMean
    
    nargoutchk(0,1)

    parameters = {'Velocity','FluxParameter'};
    nParameters = numel(parameters);
    
    for pp = 1:nParameters
        switch obj.DetrendingMethod
            case 'mean removal'
                [x,meanValue] = detrendMeanRemoval(obj.([parameters{pp},'RS']));
            case 'linear'
                [x,meanValue] = detrendLinear(obj.([parameters{pp},'RS']));
            case 'moving mean'
                window = obj.NSamplesPerWindow/2;
                [x,meanValue] = detrendMovingMean(obj.([parameters{pp},'RS']),window);
        end
        obj.([parameters{pp},'DT']) = x;
        obj.([parameters{pp},'DTMean']) = meanValue;
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end