function addDataToExistingSet(obj,setId,data)
% addDataToExistingSet  Adds data to an existing set
%   ADDDATATOEXISTINGSET adds data to an existing set of a dataStore instance
%
%   Syntax
%     ADDDATATOEXISTINGSET(obj,setId,data)
%
%   Description
%     ADDDATATOEXISTINGSET(obj,setId,data) adds data data to the set with setId
%       in the dataStore obj.
%
%   Example(s)
%     ADDDATATOEXISTINGSET(ds,2,rand(244,3))
%
%
%   Input Arguments
%     obj - dataStore instance
%       DataKit.dataStore
%         The dataStore instance to which to add the data.
%
%     setId - set Id
%       positive integer scalar | positive integer vector
%         The set Id of the set in the dataStore instance to which the data will
%         be added. 
%
%     data - data
%       numeric 2D array
%         The data to add to an existing set. The first dimension represents the
%         samples and the second dimension the variables. I.e. a 100x3 data
%         array, yields a set with 100 samples and 3 variables. The number of
%         samples has to be the same as the length of the set that the data
%         should be added to.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATASTORE, ADDDATAASNEWSET
%
%   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
%
    
    % Validate inputs
    validateSetId(obj,setId)
    validateattributes(data,{'numeric'},{'2d','nonempty'},mfilename,'data',3)
    
    % Set sizes
    nSamplesBefore          = obj.NSamples; % The number of samples in the dataStore before data addition
    [dataLength,nVariables] = size(data); % The length and number of variables in the data to be added
    setLength               = getSetLength(obj,setId); % The length of the existing set
    
    % Make sure the new data has the same length as the set it should be added to
    if dataLength ~= setLength
        error('Dingi:DataKit:dataStore:addDataToExistingSet:invalidDataLength',...
            'The data being added to set %u should have length %u. The data has length %u instead.',setId,setLength,dataLength)
    end
    
    % Append data
    data        = cast(data,obj.Type);
    obj.Data    = cat(1,obj.Data,reshape(data,[],1));
    
    % Get before values
    maskIndexSets      	= obj.IndexSets{:,'SetId'} == setId;
    setNVariablesBefore	= obj.IndexSets{maskIndexSets,{'NVariables'}};
    
    % Update IndexVariables
    tSetId      = repmat(setId,nVariables,1);
    tVariableId = setNVariablesBefore + (1:nVariables)';
    tStart      = nSamplesBefore + (1:setLength:nVariables*setLength)';
    tEnd        = nSamplesBefore + (setLength:setLength:nVariables*setLength)';
    newIndexVariables   = table(tSetId,tVariableId,tStart,tEnd,'VariableNames',{'SetId','VariableId','Start','End'});
    obj.IndexVariables  = cat(1,obj.IndexVariables,newIndexVariables);
    
    % Update IndexSets
    obj.IndexSets{maskIndexSets,{'NVariables'}} = setNVariablesBefore + nVariables;
end
