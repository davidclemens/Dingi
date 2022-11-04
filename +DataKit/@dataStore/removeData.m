function removeData(obj,setId,variableId)
   
    import UtilityKit.Utilities.arrayhom
    
    % Validate inputs
    validateSetId(obj,setId)
    validateVariableId(obj,setId,variableId)
    
    % Homogenize inputs
    [setId,variableId] = arrayhom(setId,variableId);
    removeId = cat(2,setId,variableId);
    
    % Find index rows to remove
    [~,removeQueue] = ismember(removeId,obj.IndexVariables{:,{'SetId','VariableId'}},'rows');
    removeQueue     = sort(removeQueue,'ascend');
    
    nRemoves = numel(removeQueue);
    keepRemoving = nRemoves > 0;
    while keepRemoving
        % Remove data
        s = obj.IndexVariables{removeQueue(1),'Start'};
        e = obj.IndexVariables{removeQueue(1),'End'};
        obj.Data(s:e) = [];
        
        % Remove index entries
        obj.removeIndexVariablesEntry(removeQueue(1))
        
        % Remove the now removed entry from the queue
        removeQueue(1) = [];
        removeQueue = removeQueue - 1;
        nRemoves = numel(removeQueue);
        keepRemoving = nRemoves > 0;
    end
end
