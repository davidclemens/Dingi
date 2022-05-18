function validateVariableId(obj,storeId,variableId)

    import DataKit.arrayhom
    
    validateattributes(storeId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'storeId',2);
    validateattributes(variableId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'variableId',3);
    
    [storeId,variableId] = arrayhom(storeId,variableId);
    
    im = ismember(cat(2,storeId,variableId),obj.IndexVariables{:,{'StoreId','VariableId'}},'rows');
    
    if any(~im)
        invalidVariable = find(~im,1);
        error('Dingi:DataKit:dataStore:validateVariableId:invalidVariableId',...
            '(%u, %u) is not a valid StoreId-VariableId combination.',storeId(invalidVariable),variableId(invalidVariable));
    end
end
