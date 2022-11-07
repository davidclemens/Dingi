function A = getSetChunk(obj,setId,rowSub,varSub)
% getSetChunk  Return set data chunk as array
%   GETSETCHUNK returns a data chunk of a single set in its original shape.
    
    import DataKit.dataStore.startend2ind
    
    % Input validation
    % Skipped as this is a protected method and valid inputs are assumed to reduce
    % overhead.
    
    % Deal with colon (':') subscripts
    maskIndexSets = obj.IndexSets{:,'SetId'} == setId;    
    if ischar(rowSub) && strcmp(rowSub,':')
        rowSub = 1:obj.IndexSets{maskIndexSets,'Length'};
    end
    if ischar(varSub) && strcmp(varSub,':')
        varSub = 1:obj.IndexSets{maskIndexSets,'NVariables'};
    end
    
    % Get out shape
    outShape = [numel(rowSub),numel(varSub)];

    % Get data indices
    [maskIndexVariablesInd,~] = find(...
        obj.IndexVariables{:,'SetId'} == setId & ...
        obj.IndexVariables{:,'VariableId'} == varSub);
    rowSub = rowSub(:);
    dataIndices = rowSub - 1 + obj.IndexVariables{maskIndexVariablesInd,'Start'}';
    
    % Get data
    A = reshape(obj.Data(dataIndices),outShape);
end
