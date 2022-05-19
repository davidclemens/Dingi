function data = getData(obj,setId,variableId,groupMode)

    import DataKit.arrayhom

    % Validate inputs
    validateVariableId(obj,setId,variableId)
    validGroupModes	= {'NaNSeperated','Cell'};
    groupMode       = validatestring(groupMode,validGroupModes,mfilename,'groupBy',4);

    % Homogenize inputs
    [setId,variableId]  = arrayhom(setId,variableId);
    nVariables          = numel(variableId);

    % Create mask into IndexVariable for the requested variables
    [~,imInd] = ismember(cat(2,setId,variableId),obj.IndexVariables{:,{'SetId','VariableId'}},'rows');

    dataSetIndices      = obj.IndexVariables{imInd,{'Start','End'}}; % Start and end indices in the dataStore for requested variables
    switch groupMode
        case 'NaNSeperated'
            % Get subscripts for the data sets
            dataSetSubs 	= arrayfun(@colon,dataSetIndices(:,1),dataSetIndices(:,2),'un',0);
            dataSetSubs     = cat(2,dataSetSubs{:})';

            % Get subscripts for the data output
            dataLengths     = obj.IndexSets{obj.IndexVariables{imInd,'SetId'},'Length'}; % Lengths of requested variables
            dataIndices     = cat(2,cat(1,0,cumsum(dataLengths(1:end - 1,:))) + 1,cumsum(dataLengths)) + (0:(nVariables - 1))'; % Start and end indices in the output for requested variables
            dataSubs        = arrayfun(@colon,dataIndices(:,1),dataIndices(:,2),'un',0);
            dataSubs        = cat(2,dataSubs{:})';

            % Assign data
            data            = NaN(sum(dataLengths) + nVariables - 1,1); % Initialize
            data(dataSubs)  = obj.Data(dataSetSubs); % Assign
        case 'Cell'
            data = cell(nVariables,1);
            for vv = 1:nVariables
                data{vv} = obj.Data(dataSetIndices(vv,1):dataSetIndices(vv,2));
            end
    end
end
