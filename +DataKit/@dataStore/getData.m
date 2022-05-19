function data = getData(obj,storeId,variableId,groupMode)

    import DataKit.arrayhom
    
    % Validate inputs
    validateVariableId(obj,storeId,variableId)
    validGroupModes	= {'NaNSeperated','Cell'};
    groupMode       = validatestring(groupMode,validGroupModes,mfilename,'groupBy',4);
    
    % Homogenize inputs
    [storeId,variableId] = arrayhom(storeId,variableId);
    nVariables  = numel(variableId);
    
    % Create mask into IndexVariable for the requested variables
    [~,imInd] = ismember(cat(2,storeId,variableId),obj.IndexVariables{:,{'StoreId','VariableId'}},'rows');
    
 	dataStoreIndices     = obj.IndexVariables{imInd,{'Start','End'}}; % Start and end indices in the data store for requested variables
    switch groupMode
        case 'NaNSeperated'
            % Get subscripts for the data store
            dataStoreSubs 	= arrayfun(@colon,dataStoreIndices(:,1),dataStoreIndices(:,2),'un',0);
            dataStoreSubs	= cat(2,dataStoreSubs{:})';
            
            % Get subscripts for the data output
            dataLengths     = obj.IndexStores{obj.IndexVariables{imInd,'StoreId'},'Length'}; % Lengths of requested variables
            dataIndices     = cat(2,cat(1,0,cumsum(dataLengths(1:end - 1,:))) + 1,cumsum(dataLengths)) + (0:(nVariables - 1))'; % Start and end indices in the output for requested variables
            dataSubs        = arrayfun(@colon,dataIndices(:,1),dataIndices(:,2),'un',0);
            dataSubs        = cat(2,dataSubs{:})';
            
            % Assign data
            data            = NaN(sum(dataLengths) + nVariables - 1,1); % Initialize
            data(dataSubs)  = obj.Data(dataStoreSubs); % Assign
        case 'Cell'
            data = cell(nVariables,1);
            for vv = 1:nVariables
                data{vv} = obj.Data(dataStoreIndices(vv,1):dataStoreIndices(vv,2));
            end
    end
end
