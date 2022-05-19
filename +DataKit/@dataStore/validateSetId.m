function validateSetId(obj,setId)

    validateattributes(setId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'setId',2);
    
    im = ismember(setId,obj.IndexSets{:,'SetId'});
    
    if any(~im)
        invalidSet = find(~im,1);
        error('Dingi:DataKit:dataStore:validateSetId:invalidSetId',...
            '%u is not a valid SetId.',setId(invalidSet));
    end
end
