function T = createRateTablePerDeviceDomain(obj)
% createRateTablePerDeviceDomain  Create rate table per device domain
%   CREATERATETABLEPERDEVICEDOMAIN create a table with one row per device domain
%   summarizing all fluxes of an array of bigoFluxAnalyis instances.
%
%   Syntax
%     T = CREATERATETABLEPERDEVICEDOMAIN(obj)
%
%   Description
%     T = CREATERATETABLEPERDEVICEDOMAIN(obj)  Creates a table T that
%       summarizies all fluxes of the bigoFluxAnalysis instance(s) obj.
%
%   Example(s)
%     T = CREATERATETABLEPERDEVICEDOMAIN(obj)  returns table T.
%
%
%   Input Arguments
%     obj - bigoFluxAnalysis
%       AnalysisKit.bigoFluxAnalysis array
%         An array of bigoFluxAnalyis instances from which the fluxes should be
%         extracted.
%
%
%   Output Arguments
%     T - rates table
%       table
%         The rates table summarizing the fluxes.
%
%
%   Name-Value Pair Arguments
%
%
%   See also ANALYSISKIT.BIGOFLUXANALYSIS.CREATERATETABLEPERFIT
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    % Get the rates table of all instances
    rates = cat(1,obj.Rates);
    
    % Get unique device domains
    [uDeviceDomain,~,uDeviceDomainInd] = unique(rates(:,{'Cruise','Gear','DeviceDomain'}),'rows','stable');
    nuDeviceDomain = size(uDeviceDomain,1);
    
    % Get unique variables
    uVariables = unique(rates{:,'Variable'},'stable');
    nuVariables = size(uVariables,1);
    
    % Initialize table
    tbl = cat(2,...
            table(categorical(repmat({''},nuDeviceDomain,1)),...
                'VariableNames',{'FluxUnit'}),...
            array2table(NaN(nuDeviceDomain,nuVariables),...
                'VariableNames',cellstr(uVariables)));
            
    % Loop over device domains
    for dd = 1:nuDeviceDomain    
        maskDeviceDomain = uDeviceDomainInd == dd;
        
        % Set units
        % NOTE that this assumes that all fluxes for a bigoFluxAnalysis instance have
        % the same flux units.
        tbl{dd,'FluxUnit'} = rates{find(maskDeviceDomain,1),'FluxUnit'};
        
        for vv = 1:nuVariables
            mask = maskDeviceDomain & rates{:,'Variable'} == uVariables(vv);
            if sum(mask == 1)
                % Write the mean flux to the table
                tbl{dd,cellstr(uVariables(vv))} = rates{mask,'FluxMean'};
            else
                error('Dingi:AnalysisKit:bigoFluxAnalysis:createRateTablePerDeviceDomain:MultipleDeviceDomainMatches',...
                    'Mulitple device domains matched.')
            end
        end
    end
    
    % Combine the tables
    T = cat(2,uDeviceDomain,tbl);
end
