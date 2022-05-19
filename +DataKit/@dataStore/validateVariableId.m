function validateVariableId(obj,setId,variableId)

    import DataKit.arrayhom
    
    validateattributes(setId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'setId',2);
    validateattributes(variableId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'variableId',3);
    
    [setId,variableId] = arrayhom(setId,variableId);
    
    im = ismember(cat(2,setId,variableId),obj.IndexVariables{:,{'SetId','VariableId'}},'rows');
    
    if any(~im)
        invalidVariable = find(~im,1);
        validVariables  = strjoin(strcat({'('},cellstr(num2str(obj.IndexVariables{:,'SetId'},'%u')),{','},cellstr(num2str(obj.IndexVariables{:,'VariableId'},'%u')),{')'}),', ');
        error('Dingi:DataKit:dataStore:validateVariableId:invalidVariableId',...
            '(%u,%u) is not a valid SetId-VariableId combination. Valid SetId-VariableId combinations are:\n\t%s',setId(invalidVariable),variableId(invalidVariable),validVariables);
    end
end