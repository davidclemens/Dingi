function tbl = getFlux(obj,parameters)
% GETFLUX

    [parameterIsValid,parameterInfo]   = DataKit.validateParameter(parameters);
    im              = ismember(parameterInfo{parameterIsValid,'ParameterId'},obj.fluxParameterId);
    maskParameter   = parameterIsValid & im;
    
    tbl     = table(cat(1,obj.meta(obj.indSource).dataSourceDomain),cat(1,obj.meta(obj.indSource).dataSourceId),obj.fluxParameterId(obj.indParameter)',obj.flux,strcat(obj.fluxParameterUnit(obj.indParameter)',{' L m⁻² d⁻¹'}),...
                'VariableNames',    {'DataSourceDomain','DataSourceId','ParameterId','Flux','FluxUnit'});
end