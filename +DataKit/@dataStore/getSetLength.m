function length = getSetLength(obj,setId)
    
    validateSetId(obj,setId)
    
    length = obj.IndexSets{obj.IndexSets{:,'SetId'} == setId,'Length'};
end
