function A = getSetVariable(obj,setId,variableId)
% getSetVariable  Return variable data as array
%   GETSETVARIABLE returns the data of specific variables of a single set in its
%   original shape.
    
    import DataKit.dataStore.startend2ind
    
    % Input validation
    % Skipped as this is a protected method and valid inputs are assumed to reduce
    % overhead.
    
    % Deal with colon (':') subscripts
    maskIndexSets = obj.IndexSets{:,'SetId'} == setId;
    if ischar(variableId) && strcmp(variableId,':')
        variableId = 1:obj.IndexSets{maskIndexSets,'NVariables'};
    end
    
    % Get set shape
    setShape = [obj.IndexSets{maskIndexSets,'Length'},numel(variableId)];

    % Get data indices
    [maskIndexVariablesInd,~] = find(...
        obj.IndexVariables{:,'SetId'} == setId & ...
        obj.IndexVariables{:,'VariableId'} == variableId);
    dataIndices = startend2ind(obj.IndexVariables{maskIndexVariablesInd,{'Start','End'}});

    % Get data
    A = reshape(obj.Data(dataIndices),setShape);
end
