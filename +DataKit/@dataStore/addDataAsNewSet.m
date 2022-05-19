function addDataAsNewSet(obj,data)

    validateattributes(data,{'numeric'},{'2d','nonempty'},mfilename,'data',3)

    setId = getNewSetId(obj);

    % Set sizes
    nSamplesBefore          = obj.NSamples; % The number of samples in the dataStore before data addition
    [dataLength,nVariables]	= size(data); % The length and number of variables in the data to be added
    setLength               = dataLength; % The length of the new set is equal to the length of the new data

    % Append data
    obj.Data = cat(1,obj.Data,reshape(data,[],1));

    % Update IndexVariables
    tSetId      = repmat(setId,nVariables,1);
    tVariableId = (1:nVariables)';
    tStart      = nSamplesBefore + (1:setLength:nVariables*setLength)';
    tEnd        = nSamplesBefore + (setLength:setLength:nVariables*setLength)';
    newIndexVariables   = table(tSetId,tVariableId,tStart,tEnd,'VariableNames',{'SetId','VariableId','Start','End'});
    obj.IndexVariables  = cat(1,obj.IndexVariables,newIndexVariables);

    % Update IndexSets
    newIndexSets	= table(setId,setLength,nVariables,'VariableNames',{'SetId','Length','NVariables'});
    obj.IndexSets   = cat(1,obj.IndexSets,newIndexSets);
end
