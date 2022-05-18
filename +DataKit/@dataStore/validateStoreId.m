function validateStoreId(obj,storeId)

    validateattributes(storeId,{'numeric'},{'vector','nonempty','positive','integer'},mfilename,'storeId',2);
    
    im = ismember(storeId,obj.IndexStores{:,'StoreId'});
    
    if any(~im)
        invalidStore = find(~im,1);
        error('Dingi:DataKit:dataStore:validateStoreId:invalidStoreId',...
            '%u is not a valid StoreId.',storeId(invalidStore));
    end
end
