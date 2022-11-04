function [parameterIsValid,varargout] = validateParameter(parameter,varargin)
% VALIDATEPARAMETER
    
    import UtilityKit.Utilities.table.readTableFile
    import UtilityKit.Utilities.toolbox.*

    nargoutchk(0,2)
    
	% input check: parameter
    if ischar(parameter)
        parameter	= cellstr(parameter);
    elseif ~iscellstr(parameter)
        error('Dingi:DataKit:validateParameter:invalidParameterType',...
              'The parameter(s) to validate has to be specified as a char or cellstr.')
    end
    nRequestedParameters  	= numel(parameter);
    
	% parse Name-Value pairs
    optionName          = {'Unit'}; % valid options (Name)
    optionDefaultValue  = {repmat({'<unspecified>'},nRequestedParameters,1)}; % default value (Value)
    [Unit]              = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    % input check: Unit
	if ischar(Unit)
        Unit	= cellstr(Unit);
    elseif ~iscellstr(Unit)
        error('Dingi:DataKit:validateParameter:invalidUnitType',...
              'The units of parameter(s) to validate have to be specified as a char or cellstr.')
	end
    if numel(Unit) ~= nRequestedParameters
        error('Dingi:DataKit:validateParameter:sameNumberOfUnitsAndParametersRequired',...
            'The same number of units and parameters have to be specified')
    end
    unitsProvided   = ~all(ismember(Unit,'<unspecified>'));
    
    % load remote table
    validParameters	= readTableFile([toolbox.ressources('DataKit'),'/validParameters.xlsx']);
 
    maskRequestedParameters         = false(size(validParameters,1),nRequestedParameters);
    maskRequestedParametersUnits    = false(size(validParameters,1),nRequestedParameters);
    for par = 1:nRequestedParameters
        % match parameter name
        maskRequestedParameters(:,par)   	= ~cellfun(@isempty,regexpi(cellstr(validParameters{:,'Abbreviation'}),parameter{par})) | ...
                                              ~cellfun(@isempty,regexpi(cellstr(validParameters{:,'Symbol'}),parameter{par})) | ...
                                              ~cellfun(@isempty,regexpi(cellstr(validParameters{:,'Parameter'}),parameter{par}));
        % match parameter unit
        if unitsProvided
            maskRequestedParametersUnits(:,par)	= ~cellfun(@isempty,cellfun(@(reg) regexp(Unit{par},reg),validParameters{:,'UnitRegexp'},'un',0));
        else
            maskRequestedParametersUnits        = true(size(validParameters,1),nRequestedParameters);
        end
    end
    
    % Units must match
    maskRequestedParameters     = maskRequestedParameters & maskRequestedParametersUnits;
    
    runTests()

    
    
    while any(parameterIssue)
        issueIdx   	= find(parameterHasMultipleMatches,1);
        matchIndex  = find(maskRequestedParameters(:,issueIdx));
        
        fprintf('There were %g matches for parameter ''%s'' with unit ''%s'':\n\n',nMatches(issueIdx),parameter{issueIdx},Unit{issueIdx})
        disp(cat(2,table((1:nMatches(issueIdx))','VariableNames',{'Index'}),validParameters(maskRequestedParameters(:,issueIdx),:)))
        prompt  = 'Enter index of the desired match [1], ignore [i] or cancel [c]: ';
        str     = input(prompt,'s');
        if isempty(str)
            selectionIndex = 1;
        else
            if strcmpi(str,'i')
                selectionIndex = [];
            elseif strcmpi(str,'c')

            else
                selectionIndex = str2double(str);
            end
        end
        
        tmpMask     = false(size(validParameters,1),1);
        tmpMask(matchIndex(selectionIndex)) = true;
        maskRequestedParameters(:,issueIdx) = tmpMask;
        
        runTests()
    end
    
    parameterIsValid           	= (sum(maskRequestedParameters) == 1)';
    parameterInfoIndex       	= zeros(nRequestedParameters,1);
    [parameterInfoIndex(parameterIsValid),~]	= find(maskRequestedParameters);
    
    
    % initialize
    info(nRequestedParameters + 1,:) = validParameters(1,:);
    
    info(parameterIsValid,:)    = validParameters(parameterInfoIndex(parameterIsValid),:);
    info                        = info(1:end - 1,:);
    
    varargout{1}    = info;
    
    function runTests()
        nMatches                    = sum(maskRequestedParameters)';
        parameterHasMultipleMatches	= nMatches > 1;
        
%         if unitsProvided
%             maskRequestedParametersWithUnit     = maskRequestedParameters & maskRequestedParametersUnits;
%             nMatchesWithUnit                    = sum(maskRequestedParametersWithUnit)';
%         else
%             nMatchesWithUnit                    = true(size(nMatches));
%         end
%         parameterWithUnitHasMultipleMatches	= nMatchesWithUnit > 1;
%         
%         unitIssues      = nMatches == 1 & nMatchesWithUnit == 0;
        parameterIssue  = parameterHasMultipleMatches;
    end
end
