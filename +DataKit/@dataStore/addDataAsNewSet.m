function varargout = addDataAsNewSet(obj,data)

    nargoutchk(0,1)

    validateattributes(data,{'numeric'},{'2d','nonempty'},mfilename,'data',3)

    setId = getNewSetId(obj);

    rawStoreSizeBefore      = numel(obj.Data);
    [dataLength,nVariables]	= size(data);
    setLength               = dataLength;

    % Append data
    obj.Data = cat(1,obj.Data,reshape(data,[],1));

    % Update IndexVariables
    tSetId      = repmat(setId,nVariables,1);
    tVariableId = (1:nVariables)';
    tStart      = rawStoreSizeBefore + (1:setLength:nVariables*setLength)';
    tEnd        = rawStoreSizeBefore + (setLength:setLength:nVariables*setLength)';
    newIndexVariables   = table(tSetId,tVariableId,tStart,tEnd,'VariableNames',{'SetId','VariableId','Start','End'});
    obj.IndexVariables  = cat(1,obj.IndexVariables,newIndexVariables);

    % Update IndexSets
    newIndexSets	= table(setId,setLength,nVariables,'VariableNames',{'SetId','Length','NVariables'});
    obj.IndexSets   = cat(1,obj.IndexSets,newIndexSets);

    if nargout == 1
        varargout{1} = obj;
    end
end
