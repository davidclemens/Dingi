function addDataAsNewSet(obj,data)
% addDataAsNewSet  Adds data as a new set
%   ADDDATAASNEWSET adds data as a new set to a dataStore instance
%
%   Syntax
%     ADDDATAASNEWSET(obj,data)
%
%   Description
%     ADDDATAASNEWSET(obj,data) adds data data as a new set in the dataStore obj
%
%   Example(s)
%     ADDDATAASNEWSET(ds,rand(244,3))
%
%
%   Input Arguments
%     obj - dataStore instance
%       DataKit.dataStore
%         The dataStore instance to which to add the data.
%
%     data - data
%       numeric 2D array
%         The data to add as a new set. The first dimension represents the
%         samples and the second dimension the variables. I.e. a 100x3 data
%         array, yields a set with 100 samples and 3 variables.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATASTORE, ADDDATATOEXISTINGSET
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%

    % Validate input
    validateattributes(data,{'numeric'},{'2d','nonempty'},mfilename,'data',3)

    % Retrieve set Id
    setId = getNewSetId(obj);

    % Set sizes
    nSamplesBefore          = obj.NSamples; % The number of samples in the dataStore before data addition
    [dataLength,nVariables]	= size(data); % The length and number of variables in the data to be added
    setLength               = dataLength; % The length of the new set is equal to the length of the new data

    % Append data
    data        = cast(data,obj.Type);
    obj.Data    = cat(1,obj.Data,reshape(data,[],1));

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
