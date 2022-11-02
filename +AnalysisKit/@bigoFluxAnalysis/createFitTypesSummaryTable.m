function T = createFitTypesSummaryTable(obj)

    T = table();
    
    for oo = 1:numel(obj)
        % Create table
        Tnew = table(...
            oo.*ones(obj(oo).NFits,1),...
            (1:obj(oo).NFits)',...
            categorical(obj(oo).FitTypes'),...
            obj(oo).FitDeviceDomains,...
            obj(oo).FitVariables,...
            'VariableNames',{'IndexInstance','IndexFitTypes','FitType','DeviceDomain','Variable'});

        % Remove exclusions
        excluded = obj(oo).ExcludeFluxParameter';
        Tnew = Tnew(~excluded,:);
        
        T = cat(1,T,Tnew);
    end
end
