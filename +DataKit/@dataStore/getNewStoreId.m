function storeId = getNewStoreId(obj)
    
    if isempty(obj.IndexStores)
        storeId = 1;
    else
        storeId = max(obj.IndexStores{:,'StoreId'}) + 1;
    end
end
