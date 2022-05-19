function length = getSetLength(obj,setId)
% getSetLength  Returns the set length
%   GETSETLENGTH returns the data length of a set of a dataStore instance.
    
    % Make sure the setId is valid
    validateSetId(obj,setId)
    
    % Calculate the data Length
    length = obj.IndexSets{obj.IndexSets{:,'SetId'} == setId,'Length'};
end
