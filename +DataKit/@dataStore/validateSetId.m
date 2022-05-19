function validateSetId(obj,setId)

    validateattributes(setId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'setId',2);
    
    im = ismember(setId,obj.IndexSets{:,'SetId'});
    
    if any(~im)
        invalidSet  = find(~im,1);
        validSets   = strjoin(cellstr(num2str(obj.IndexSets{:,'SetId'},'%u')),', ');
        error('Dingi:DataKit:dataStore:validateSetId:invalidSetId',...
            '%u is not a valid set Id. Valid set Ids are:\n\t%s',setId(invalidSet),validSets);
    end
end
