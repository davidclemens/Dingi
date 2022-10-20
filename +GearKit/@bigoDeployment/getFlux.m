function tbl = getFlux(obj,variables)
% getFlux  Returns table of flux analysis results
%   GETFLUX returns a single table of flux analysis resuls for an array of 
%     bigoDeployments.
%
%   Syntax
%     tbl = GETFLUX(obj,variables)
%
%   Description
%     tbl = GETFLUX(obj,variables) returns a single table tbl of flux analysis
%       results for all variables variables of all bigoDeployments obj.
%
%   Example(s)
%     tbl = GETFLUX(obj,{'Oxygen','DissolvedInorganicCarbon'})
%
%
%   Input Arguments
%     obj - bigoDeployment
%       GearKit.bigoDeployment vector
%         A vector of GearKit.bigoDeployment instances.
%
%     variables - list of variables
%       cellstr
%         A list of variables to return.
%
%
%   Output Arguments
%     tbl - flux table
%       table
%         Table holding all flux analysis results of bigoDeployment obj.
%
%
%   Name-Value Pair Arguments
%
%
%   See also AnalysisKit.bigoFluxAnalysis
%
%   Copyright (c) 2021-2022 David Clemens (dclemens@geomar.de)
%

    nObj    = numel(obj);
    
    tbl     = table();
    for oo = 1:nObj
        tblNew	= obj(oo).analysis.Rates(ismember(obj(oo).analysis.Rates{:,'Variable'},variables),:);        
        tbl     = cat(1,tbl,tblNew);
    end
end
