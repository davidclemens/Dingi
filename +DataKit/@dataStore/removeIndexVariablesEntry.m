function removeIndexVariablesEntry(obj,row)
    
    indexVariables  = obj.IndexVariables;
    indexSets       = obj.IndexSets;
    
    dataStart   = indexVariables{row,'Start'};
    dataEnd     = indexVariables{row,'End'};
    rowSetId    = indexVariables{row,'SetId'};
    
    indexShift  = dataEnd - dataStart + 1; % The number of removed data points
    
    % Remove the index row
    indexVariables(row,:) = [];
        
    % Shift the indices behind the removed block forward by indexShift
    indexVariables{row:end,{'Start','End'}} = indexVariables{row:end,{'Start','End'}} - indexShift;

    % Reindex the variableIds for the affected set
    maskAffectedSet = indexVariables{:,'SetId'} == rowSetId;
    nVariablesToReindex = sum(maskAffectedSet);
    if nVariablesToReindex == 0
        % The set was removed entirely. Reindex the set ids.
        
        % Reindex set ids in the indexVariables table
        indexVariables{row:end,'SetId'} = indexVariables{row:end,'SetId'} - 1;
        
        % Remove the row in the indexSets table
        indexSets(rowSetId,:) = [];
        
        % Reindex the indexSets table
        indexSets{rowSetId:end,'SetId'} = indexSets{rowSetId:end,'SetId'} - 1;
    else
        % Only one variable was removed from the set. Other variables in that set
        % remain. Reindex the variable ids.
        indexVariables{maskAffectedSet,'VariableId'} = (1:nVariablesToReindex)';
        indexSets{rowSetId,'NVariables'} = indexSets{rowSetId,'NVariables'} - 1;
    end
    
    obj.IndexVariables  = indexVariables;
    obj.IndexSets       = indexSets;
end
