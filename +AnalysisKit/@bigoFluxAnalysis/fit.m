function obj = fit(obj,varargin)
% FIT

    switch obj.fitType
        case 'linear'
            
            
        otherwise
            error('AnalysisKit:bigoFluxAnalysis:fit:unknownFitType',...
                'The fit type ''%s'' is not defined yet.',obj.fitType)
    end
end