function varargout = addDataToExistingStore(obj,storeId,data)

    nargoutchk(0,1)
    
    validateStoreId(obj,storeId)
    validateattributes(data,{'numeric'},{'2d','nonempty'},mfilename,'data',3)
    
    rawStoreSizeBefore = numel(obj.Data);
    [dataLength,nVariables] = size(data);
    storeLength = getStoreLength(obj,storeId);
    
    if dataLength ~= storeLength
        error('Dingi:DataKit:dataStore:addDataToExistingStore:invalidDataLength',...
            'The data being added to store %u should have length %u. The data has length %u instead.',storeId,storeLength,dataLength)
    end
    
    % Append data
    obj.Data = cat(1,obj.Data,reshape(data,[],1));
    
    % Get before values
    maskIndexStores         = obj.IndexStores{:,'StoreId'} == storeId;
    storeNVariablesBefore   = obj.IndexStores{maskIndexStores,{'NVariables'}};
    
    % Update IndexVariables
    tStoreId    = repmat(storeId,nVariables,1);
    tVariableId = storeNVariablesBefore + (1:nVariables)';
    tStart      = rawStoreSizeBefore + (1:storeLength:nVariables*storeLength)';
    tEnd        = rawStoreSizeBefore + (storeLength:storeLength:nVariables*storeLength)';
    newIndexVariables   = table(tStoreId,tVariableId,tStart,tEnd,'VariableNames',{'StoreId','VariableId','Start','End'});
    obj.IndexVariables  = cat(1,obj.IndexVariables,newIndexVariables);
    
    % Update IndexStores
    obj.IndexStores{maskIndexStores,{'NVariables'}} = storeNVariablesBefore + nVariables;
    
    if nargout == 1
        varargout{1} = obj;
    end
end
