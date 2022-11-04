function T = createFitTypesSummaryTable(obj)
% createFitTypesSummaryTable  Create fit types table
%   CREATEFITTYPESSUMMARYTABLE creates a table that summarizes all fit types for
%   an array of bigoFluxAnalysis instances.
%
%   Syntax
%     T = CREATEFITTYPESSUMMARYTABLE(obj)
%
%   Description
%     T = CREATEFITTYPESSUMMARYTABLE(obj)  Creates a table T that
%       summarizies all fit types of the bigoFluxAnalysis instance(s) obj.
%
%   Example(s)
%     T = CREATEFITTYPESSUMMARYTABLE(obj)  rreturns table T.
%
%
%   Input Arguments
%     obj - bigoFluxAnalysis
%       AnalysisKit.bigoFluxAnalysis array
%         An array of bigoFluxAnalyis instances from which the fit types should
%         be extracted.
%
%
%   Output Arguments
%     T - rates table
%       table
%         The fit types table summarizing all fit types.
%
%
%   Name-Value Pair Arguments
%
%
%   See also ANALYSISKIT.BIGOFLUXANALYSIS.DISPFITTYPESSUMMARY
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    T = table();
    
    for oo = 1:numel(obj)
        % Create table
        Tnew = table(...
            oo.*ones(obj(oo).NFits,1),...
            (1:obj(oo).NFits)',...
            categorical(obj(oo).FitTypes),...
            obj(oo).FitDeviceDomains,...
            obj(oo).FitVariables,...
            'VariableNames',{'IndexInstance','IndexFitTypes','FitType','DeviceDomain','Variable'});

        % Remove exclusions
        excluded = obj(oo).ExcludeFluxParameter';
        Tnew = Tnew(~excluded,:);
        
        T = cat(1,T,Tnew);
    end
end
