function setId = getNewSetId(obj)
    
    if isempty(obj.IndexSets)
        setId = 1;
    else
        setId = max(obj.IndexSets{:,'SetId'}) + 1;
    end
end
