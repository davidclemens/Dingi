function tbl = getFlux(obj,parameters)
% GETFLUX

    [parameterIsValid,parameterInfo]   = DataKit.validateParameter(parameters);
    im              = ismember(parameterInfo{:,'ParameterId'},obj.fluxParameterId);
    maskParameter   = parameterIsValid & im;
    
    tbl     = table(cat(1,obj.meta(obj.indSource).dataSourceDomain),cat(1,obj.meta(obj.indSource).dataSourceId),obj.fluxParameterId(obj.indParameter)',obj.fluxStatistics,obj.flux,strcat(obj.fluxParameterUnit(obj.indParameter)',{' L m⁻² d⁻¹'}),obj.fitObjects,...
                'VariableNames',    {'DataSourceDomain','DataSourceId','ParameterId','FluxStatistics','Flux','FluxUnit','FitObject'});
	[rowIm] = ismember(tbl{:,'ParameterId'},parameterInfo{maskParameter,'ParameterId'});
    tbl     = tbl(rowIm,:);     
end