function setRateTable(obj)
% setRateTable  update backend property Rates
%   SETRATETABLE updates the backend property Rates_.
%
%   Syntax
%     SETRATETABLE(obj)
%
%   Description
%     SETRATETABLE(obj)  Updates the backend property Rates_.
%
%   Example(s)
%     SETRATETABLE(obj)
%
%
%   Input Arguments
%     obj - bigoFluxAnalysis
%       AnalysisKit.bigoFluxAnalysis scalar
%         A bigoFluxAnalyis scalar.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also 
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    % Create rate table
    rates = obj.createRateTablePerFit;
    
    % Set backend property
    obj.Rates_ = rates;
end
