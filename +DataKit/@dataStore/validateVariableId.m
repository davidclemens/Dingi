function validateVariableId(obj,setId,variableId)

    import DataKit.arrayhom
    
    validateattributes(setId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'setId',2);
    validateattributes(variableId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'variableId',3);
    
    [setId,variableId] = arrayhom(setId,variableId);
    
    im = ismember(cat(2,setId,variableId),obj.IndexVariables{:,{'SetId','VariableId'}},'rows');
    
    if any(~im)
        invalidVariable = find(~im,1);
        error('Dingi:DataKit:dataStore:validateVariableId:invalidVariableId',...
            '(%u, %u) is not a valid SetId-VariableId combination.',setId(invalidVariable),variableId(invalidVariable));
    end
end
