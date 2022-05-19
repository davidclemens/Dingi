function addDataToExistingSet(obj,setId,data)
    
    validateSetId(obj,setId)
    validateattributes(data,{'numeric'},{'2d','nonempty'},mfilename,'data',3)
    
    rawStoreSizeBefore      = numel(obj.Data);
    [dataLength,nVariables] = size(data);
    setLength               = getSetLength(obj,setId);
    
    if dataLength ~= setLength
        error('Dingi:DataKit:dataStore:addDataToExistingSet:invalidDataLength',...
            'The data being added to set %u should have length %u. The data has length %u instead.',setId,setLength,dataLength)
    end
    
    % Append data
    obj.Data = cat(1,obj.Data,reshape(data,[],1));
    
    % Get before values
    maskIndexSets      	= obj.IndexSets{:,'SetId'} == setId;
    setNVariablesBefore	= obj.IndexSets{maskIndexSets,{'NVariables'}};
    
    % Update IndexVariables
    tSetId      = repmat(setId,nVariables,1);
    tVariableId = setNVariablesBefore + (1:nVariables)';
    tStart      = rawStoreSizeBefore + (1:setLength:nVariables*setLength)';
    tEnd        = rawStoreSizeBefore + (setLength:setLength:nVariables*setLength)';
    newIndexVariables   = table(tSetId,tVariableId,tStart,tEnd,'VariableNames',{'SetId','VariableId','Start','End'});
    obj.IndexVariables  = cat(1,obj.IndexVariables,newIndexVariables);
    
    % Update IndexSets
    obj.IndexSets{maskIndexSets,{'NVariables'}} = setNVariablesBefore + nVariables;
end
