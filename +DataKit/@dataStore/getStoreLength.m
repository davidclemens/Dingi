function length = getStoreLength(obj,storeId)
    
    validateStoreId(obj,storeId)
    
    length = obj.IndexStores{obj.IndexStores{:,'StoreId'} == storeId,'Length'};
end
