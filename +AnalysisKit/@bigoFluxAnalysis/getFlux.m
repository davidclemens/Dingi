function tbl = getFlux(obj,variables)
% GETFLUX
    import DataKit.Metadata.variable.validate
    
    [variableIsValid,variableInfo]   = validate('Variable',variables(:));
    im              = ismember(cat(1,variableInfo.EnumerationMemberName),obj.FitVariables);
    maskVariable    = variableIsValid & im;
    
    tbl     = table(obj.FitDeviceDomains,obj.FitVariables,obj.FluxStatistics,obj.FitGOF,obj.FluxConfInt,obj.Flux,obj.FitObjects,...
                'VariableNames',    {'DeviceDomain','Variable','FluxStatistics','FluxGOF','FluxConfidenceInterval','Flux','FitObject'});
	[rowIm] = ismember(tbl{:,'Variable'},cat(1,variableInfo(maskVariable).EnumerationMemberName));
    tbl     = tbl(rowIm,:);     
end