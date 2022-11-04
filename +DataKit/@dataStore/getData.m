function data = getData(obj,setId,variableId,groupMode)
% getData  Retrieve data from dataStore
%   GETDATA retrieves data form a dataStore instance
%
%   Syntax
%     data = GETDATA(obj,setId,variableId,groupMode)
%
%   Description
%     data = GETDATA(obj,setId,variableId,groupMode) retrieves the data of
%       variable(s) variableId in set(s) setId of dataStore instance obj and
%       returns it according to groupMode either as a NaN-seperated vector or as
%       a cell array with each cell containing the data of one variable or each
%       cell containing the data of one set.
%
%   Example(s)
%     data = GETDATA(ds,2,1,'NaNSeperated')
%     data = GETDATA(ds,2,1,'CellByVariable')
%     data = GETDATA(ds,2,1:3,'NaNSeperated')
%     data = GETDATA(ds,2:4,1:3,'NaNSeperated')
%     data = GETDATA(ds,1,[5,8:10],'NaNSeperated')
%     data = GETDATA(ds,[2,4],3,'NaNSeperated')
%     data = GETDATA(ds,[2,4,4,4],[3,7:9],'CellBySet')
%
%
%   Input Arguments
%     obj - dataStore instance
%       DataKit.dataStore
%         The dataStore instance from which to retrieve the data.
%
%     setId - set Id
%       positive integer scalar | positive integer vector
%         Defines the data to be retrieved from the dataStore instance together
%         with the corresponding variableId. Each (setId,variableId)-pair
%         uniquely identifies data in the dataStore. Scalar setId/variableId
%         inputs are repeated to match the shape of non-scalar
%         setId/variableId inputs. All non-scalar setId/variableId inputs
%         have to have the same shape.
%
%     variableId - variable Id
%       positive integer scalar | positive integer vector
%         Defines the data to be retrieved from the dataStore instance together
%         with the corresponding setId. Each (setId,variableId)-pair
%         uniquely identifies data in the dataStore. Scalar setId/variableId
%         inputs are repeated to match the shape of non-scalar
%         setId/variableId inputs. All non-scalar setId/variableId inputs
%         have to have the same shape.
%
%     groupMode - group mode
%       'NaNSeperated' | 'CellByVariable' | 'CellBySet'
%         Sets the data return strategy:
%         - NaNSeperated:   Returns all requested variable data in a column
%                           vector in sequence, seperated by NaNs.
%         - CellByVariable: Returns each requested variable data as a column
%                           vector within a cell.
%         - CellBySet:      Returns each requested variable data as an array per
%                           set contained in a cell.
%
%
%   Output Arguments
%     data - output data
%       numeric column vector | cell
%         Output data. The type depends on the groupMode input argument: For
%         'NaNSeperated' the type is double or single and for 'Cell' it is a
%         cell array.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATASTORE
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    import UtilityKit.Utilities.arrayhom
    
    narginchk(4,4)
    
    % Validate inputs
    validateVariableId(obj,setId,variableId)
    validGroupModes	= {'NaNSeperated','CellByVariable','CellBySet'};
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
            data            = NaN(sum(dataLengths) + nVariables - 1,1,obj.Type); % Initialize
            data(dataSubs)  = obj.Data(dataSetSubs); % Assign
        case 'CellByVariable'
            data = cell(nVariables,1);
            for vv = 1:nVariables
                data{vv} = obj.Data(dataSetIndices(vv,1):dataSetIndices(vv,2));
            end            
        case 'CellBySet'
            [uSetIds,~,uSetIdsInd] = unique(setId,'Stable');
            nuSetIds = numel(uSetIds);
            data = cell(nuSetIds,1);
            for ii = 1:nuSetIds
                mask = uSetIdsInd == ii;
                indices = arrayfun(@(s,e) s:e,dataSetIndices(mask,1),dataSetIndices(mask,2),'un',0);
                indices = cat(2,indices{:});
                data{ii} = reshape(obj.Data(indices),obj.IndexSets{uSetIds(ii),'Length'},[]);
            end
    end
end
