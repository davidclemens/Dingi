function setId = getNewSetId(obj)
% getNewSetId  Retrieve a new unused set Id
%   GETNEWSETID retrieves a new set Id for a dataStore that is not used yet.
    
    if isempty(obj.IndexSets)
        setId = 1;
    else
        setId = max(obj.IndexSets{:,'SetId'}) + 1;
    end
end
