function [parameterIdIsValid,varargout] = validateParameterId(parameterId)
% VALIDATEPARAMETERID
    
    import UtilityKit.Utilities.table.readTableFile
    import UtilityKit.Utilities.toolbox.*
    
    nargoutchk(0,2)
   
    nRequestedParameters  	= numel(parameterId);
   
    validParameters         = readTableFile([toolbox.ressources('DataKit'),'/validParameters.xlsx']);
     
    [parameterIdIsValid,parameterInfoIndex] = ismember(parameterId,validParameters{:,'ParameterId'});

    % initialize
    info(nRequestedParameters + 1,:) = validParameters(1,:);
    
    info(parameterIdIsValid,:)      = validParameters(parameterInfoIndex(parameterIdIsValid),:);
    info                            = info(1:end - 1,:);
    
    varargout{1}    = info;
end
