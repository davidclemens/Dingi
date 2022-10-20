function fitTypes = validateFitTypes(obj,C)
% validateFitTypes  Validate fit type cellstr
%   VALIDATEFITTYPES validates a cellstr of fit types.
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    % Validate type
    if ischar(C)
        C = cellstr(C);
    else
        assert(iscellstr(C),...
            'Dingi:AnalysisKit:bigoFluxAnalysis:validateFitTypes:invalidType',...
            'Fit types have to be provided as char row vector or cellstr. It was %s instead', class(C))
    end
    
    % Validate shape
    validateattributes(C,{'cell'},{'size',[1,obj.NFits]},mfilename,'C')
    
    % Validate fit types
    fitTypes = cellfun(@(s) validatestring(s,obj.ValidFitTypes),C,'un',0);
end
