function dispFitTypesSummary(obj)
% dispFitTypesSummary  Display a summary of FitTypes
%   DISPFITTYPESSUMMARY display a summary of the FitTypes property of all
%   bigoFluxAnalysis fits that are not excluded.
%
%   Syntax
%     DISPFITTYPESSUMMARY(obj)
%
%   Description
%     DISPFITTYPESSUMMARY(obj)  Display the FitTypes summary of a 
%       bigoFluxAnalysis with additional metadata: It's corresponding index, 
%       variable and device domain.
%
%   Example(s)
%     DISPFITTYPESSUMMARY(obj)
%
%
%   Input Arguments
%     obj - bigoFluxAnalysis instance
%       AnalysisKit.bigoFluxAnalysis
%         A bigoFluxAnalysis instance of which the currently set FitTypes
%         property and its corresponding metadata should be displayed. This
%         output can be used to find the index to manually set the fit type for
%         a specific fit variable.
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
    
    % Display table
    disp(obj.createFitTypesSummaryTable)
    
    fprintf('%u fit variables are excluded over %u bigoFluxAnalysis instances (e.g. because there were not enough data points) and are not shown here.\n',sum([obj.ExcludeFluxParameter]),numel(obj))
end
