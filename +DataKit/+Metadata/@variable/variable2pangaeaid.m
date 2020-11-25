function id = variable2pangaeaid(obj)


    fId             = fopen([getToolboxRessources('DataKit'),obj(1).PangaeaParameterListFilename],'r');
    variableList	= textscan(fId,'%C%C%C%u',...
                        'Delimiter',    '\t',...
                        'HeaderLines',  1);
    fclose(fId);
    variableList 	= table(variableList{:},...
                        'VariableNames',    {'Variable','Abbreviation','Unit','VariableId'});

    variableName        = obj.variable2str;
    nVariables          = numel(variableName);
    id                  = zeros(nVariables,'uint16');
    for var = 1:nVariables
        maskMatch       = ~cellfun(@isempty,regexpi(cellstr(variableList{:,'Abbreviation'}),variableName{var})) | ...
                     	  ~cellfun(@isempty,regexpi(cellstr(variableList{:,'Variable'}),variableName{var}));
    
        matchParameterList          = variableList(maskMatch,:);
        matchParameterList.Index    = (1:size(matchParameterList,1))';
        matchParameterList          = matchParameterList(:,[end,1:end - 1]);
        nMatches            = size(matchParameterList,1);
        if nMatches > 1
            fprintf('There were %g matches for ''%s'' (element %g of %g):\n\n',nMatches,variableName{var},var,nVariables)
            disp(matchParameterList)
            prompt  = 'Enter index of the desired match [1] or cancel [c]: ';
            str     = input(prompt,'s');
            if isempty(str)
                index = 1;
            else
                if strcmpi(str,'c')
                    fprintf('cancelled\n')
                    clear id
                    return
                else
                    index = str2double(str);
                end
            end

        elseif nMatches == 1
            index = 1;
        else
            warning('No match for variable ''%s''.',variableName{var})
            continue
        end
        id(var)   = matchParameterList{index,'VariableId'};
  	end
end