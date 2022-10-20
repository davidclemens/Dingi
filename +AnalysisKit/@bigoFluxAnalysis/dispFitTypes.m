function dispFitTypes(obj)
% dispFitTypes  Display list of FitTypes
%   DISPFITTYPES display a list of the FitTypes property of all bigoFluxAnalysis
%   fits that are not excluded.
%
%   Syntax
%     DISPFITTYPES(obj)
%
%   Description
%     DISPFITTYPES(obj)  Display the FitTypes property of a bigoFluxAnalysis
%       instance with additional metadata: It's corresponding index, variable
%       and device domain.
%
%   Example(s)
%     DISPFITTYPES(obj)
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
    
    % Create table
    fitTypesTbl = table(...
        (1:obj.NFits)',...
        categorical(obj.FitTypes'),...
        categorical({obj.FitVariables.Abbreviation}'),...
        categorical({obj.FitDeviceDomains.Abbreviation}'),...
        'VariableNames',{'Index','FitType','Variable','DeviceDomain'});

    % Remove exclusions
    excluded = obj.ExcludeFluxParameter';
    fitTypesTbl = fitTypesTbl(~excluded,:);   
    
    % Display table
    disp(fitTypesTbl)
    
    fprintf('%u fit variables are excluded (e.g. because there were not enough data points) and are not shown here.\n',sum(excluded))
end
