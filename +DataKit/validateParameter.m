function [parameterIsValid,varargout] = validateParameter(parameter)
% VALIDATEPARAMETER
    
    nargoutchk(0,2)
    
    
	% input check: parameter
    if ischar(parameter)
        parameter	= cellstr(parameter);
    elseif ~iscellstr(parameter)
        error('DataKit:validateParameter:invalidParameterType',...
              'The parameter(s) to validate has to be specified as a char or cellstr.')
    end
    nRequestedParameters  	= numel(parameter);
    
    
    validParameters         = DataKit.importTableFile([getToolboxRessources('DataKit'),'/validParameters.xlsx']);
 
    maskRequestedParameters = false(size(validParameters,1),nRequestedParameters);
    for par = 1:nRequestedParameters
        maskRequestedParameters(:,par)	= ~cellfun(@isempty,regexpi(cellstr(validParameters{:,'Abbreviation'}),parameter{par})) | ...
                                          ~cellfun(@isempty,regexpi(cellstr(validParameters{:,'Symbol'}),parameter{par})) | ...
                                          ~cellfun(@isempty,regexpi(cellstr(validParameters{:,'Parameter'}),parameter{par}));
    end

    nMatches                    = sum(maskRequestedParameters)';
    parameterHasMultipleMatches	= nMatches > 1;
    
    
    while any(parameterHasMultipleMatches)
        idx         = find(parameterHasMultipleMatches,1);
        matchIndex  = find(maskRequestedParameters(:,idx));
        
        fprintf('There were %g matches for parameter ''%s'':\n\n',nMatches(idx),parameter{idx})
        disp(cat(2,table((1:nMatches(idx))','VariableNames',{'Index'}),validParameters(maskRequestedParameters(:,idx),:)))
        prompt  = 'Enter index of the desired match [1] or cancel [c]: ';
        str     = input(prompt,'s');
        if isempty(str)
            selectionIndex = 1;
        else
            if strcmpi(str,'c')

            else
                selectionIndex = str2double(str);
            end
        end
        
        tmpMask     = false(size(validParameters,1),1);
        tmpMask(matchIndex(selectionIndex)) = true;
        maskRequestedParameters(:,idx) = tmpMask;
        
        nMatches                    = sum(maskRequestedParameters)';
        parameterHasMultipleMatches	= nMatches > 1;
    end
    
    parameterIsValid           	= (sum(maskRequestedParameters) == 1)';
    parameterInfoIndex       	= zeros(nRequestedParameters,1);
    [parameterInfoIndex(parameterIsValid),~]	= find(maskRequestedParameters);
    
    
    % initialize
    info(nRequestedParameters + 1,:) = validParameters(1,:);
    
    info(parameterIsValid,:)    = validParameters(parameterInfoIndex(parameterIsValid),:);
    info                        = info(1:end - 1,:);
    
    varargout{1}    = info;
end