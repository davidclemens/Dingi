function varargout = addDataToNewStore(obj,data)

    nargoutchk(0,1)
    
    validateattributes(data,{'numeric'},{'2d','nonempty'},mfilename,'data',3)
    
    storeId = getNewStoreId(obj);
    
    rawStoreSizeBefore = numel(obj.Data);
    [dataLength,nVariables]	= size(data);
    storeLength = dataLength;
    
    % Append data
    obj.Data = cat(1,obj.Data,reshape(data,[],1));
    
    % Update IndexVariables
    tStoreId    = repmat(storeId,nVariables,1);
    tVariableId = (1:nVariables)';
    tStart      = rawStoreSizeBefore + (1:storeLength:nVariables*storeLength)';
    tEnd        = rawStoreSizeBefore + (storeLength:storeLength:nVariables*storeLength)';
    newIndexVariables   = table(tStoreId,tVariableId,tStart,tEnd,'VariableNames',{'StoreId','VariableId','Start','End'});
    obj.IndexVariables  = cat(1,obj.IndexVariables,newIndexVariables);
    
    % Update IndexStores
    newIndexStores  = table(storeId,storeLength,nVariables,'VariableNames',{'StoreId','Length','NVariables'});
    obj.IndexStores = cat(1,obj.IndexStores,newIndexStores);
    
    if nargout == 1
        varargout{1} = obj;
    end
end
