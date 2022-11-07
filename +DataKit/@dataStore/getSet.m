function A = getSet(obj,setId)
% getSet  Return set data as array
%   GETSET returns the data of a single set in its original shape.
    
    import DataKit.dataStore.startend2ind
    
    % Input validation
    % Skipped as this is a protected method and valid inputs are assumed to reduce
    % overhead.
    
    % Get set shape
    maskIndexSets = obj.IndexSets{:,'SetId'} == setId;
    setShape = obj.IndexSets{maskIndexSets,{'Length','NVariables'}};

    % Get data indices
    maskIndexVariables = obj.IndexVariables{:,'SetId'} == setId;
    dataIndices = startend2ind(obj.IndexVariables{maskIndexVariables,{'Start','End'}});

    % Get data
    A = reshape(obj.Data(dataIndices),setShape);
end
