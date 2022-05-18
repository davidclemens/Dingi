classdef dataStore < handle
    
    properties
        Data
        Type
        IndexVariables table = table([],[],[],[],'VariableNames',{'StoreId','VariableId','Start','End'})
        IndexStores table = table([],[],[],'VariableNames',{'StoreId','Length','NVariables'})
    end
    
    % Constructor method
    methods
        function obj = dataStore()
            
        end
    end
    
    methods
        varargout = addDataToExistingStore(obj,storeId,data)
        varargout = addDataToNewStore(obj,data)
        data = getData(obj,storeId,variableId,groupBy)
    end
    methods (Access = 'private')
        length = getStoreLength(obj,storeId)
        validateStoreId(obj,storeId)
        validateVariableId(obj,storeId,variableId)
        storeId = getNewStoreId(obj)
    end
end
