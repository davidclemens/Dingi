classdef dataStore < handle
    
    properties (SetAccess = 'private')
        Type char = 'single'
        IndexVariables table = table([],[],[],[],'VariableNames',{'SetId','VariableId','Start','End'})
        IndexSets table = table([],[],[],'VariableNames',{'SetId','Length','NVariables'})        
    end
    properties (Access = 'protected')
        Data = single.empty
    end
    properties (Dependent)
        NSamples
        NSets
        NVariables
        Bytes
        GBytes
        BytesPerSample
    end
    
    % Constructor method
    methods
        function obj = dataStore(varargin)
        % dataStore  Creates a dataStore instance
        %   DATASTORE creates a dataStore instance, assigns data and sets the data type.
        %
        %   Syntax
        %     obj = DATASTORE()
        %     obj = DATASTORE(data)
        %     obj = DATASTORE(data,type)
        %
        %   Description
        %     obj = DATASTORE() creates an empty dataStore instance. The default
        %       datatype is single.
        %     obj = DATASTORE(data) creates a dataStore instance with data data assigned
        %       to the first set. The datatype is set to the class of data.
        %     obj = DATASTORE(data,type) additionally allows the specification of the
        %       datatype. If data differs in its type, it is cast to type.
        %
        %   Example(s)
        %     ds = DATASTORE()
        %     ds = DATASTORE(single(magic(100)))
        %     ds = DATASTORE(magic(100),'uint8')
        %
        %
        %   Input Arguments
        %     data - data
        %       numeric 2D array
        %         The data to add as a new set. The first dimension represents the
        %         samples and the second dimension the variables. I.e. a 100x3 data
        %         array, yields a set with 100 samples and 3 variables.
        %
        %     type - datatype
        %       'single' (default) | 'double'
        %         Sets the datatype of the dataStore. If the class of data differes from
        %         type, it is cast to class type.
        %
        %
        %   Output Arguments
        %     obj - dataStore instance
        %       DataKit.dataStore
        %         The created dataStore instance.
        %
        %
        %   Name-Value Pair Arguments
        %
        %
        %   See also 
        %
        %   Copyright (c) 2022-2022 David Clemens (dclemens@geomar.de)
        %
            
            % Assign inputs
            narginchk(0,2)
            if nargin == 0
                return
            elseif nargin == 1
                data = varargin{1};
                type = class(data);
            elseif nargin == 2
                data = varargin{1};
                type = varargin{2};
            end
            
            % Create set
            obj.setType(type);
            obj.addDataAsNewSet(data);
        end
    end
    
    methods
        addDataToExistingSet(obj,setId,data)
        addDataAsNewSet(obj,data)
        removeData(obj,setId,variableId)
        data = getData(obj,setId,variableId,groupMode)
        varargout = subsref(obj,S)
    end
    methods (Access = 'protected')
        setType(obj,type)
        length = getSetLength(obj,setId)
        validateSetId(obj,setId)
        validateVariableId(obj,setId,variableId)
        setId = getNewSetId(obj)
        removeIndexVariablesEntry(obj,row)
        A = getSet(obj,setId)
        A = getSetVariable(obj,setId,variableId)
        A = getSetChunk(obj,setId,rowSub,varSub)
    end
    methods (Static, Access = 'protected')
        ind = startend2ind(indStart,indEnd)
    end
    
    % GET methods
    methods
        function nSamples = get.NSamples(obj)
            nSamples = numel(obj.Data);
        end
        function nSets = get.NSets(obj)
            nSets = size(obj.IndexSets,1);
        end
        function nVariables = get.NVariables(obj)
            nVariables = sum(obj.IndexSets{:,'NVariables'});
        end
        function bytes = get.Bytes(obj)
            prop    = obj.Data;
            s       = whos('prop');
            bytes   = s.bytes;
        end
        function gBytes = get.GBytes(obj)
            gBytes	= round(obj.Bytes.*1e-6,3);
        end
        function bytesPerSample = get.BytesPerSample(obj)
            bytesPerSample = round(obj.Bytes/obj.NSamples,1);
        end
    end
    
    % SET methods
    methods
        function obj = set.IndexVariables(obj,value)
            % Make sure the IndexVariables table is always sorted
            valueSorted = sortrows(value,'Start','ascend');
            obj.IndexVariables = valueSorted;
        end
        function obj = set.IndexSets(obj,value)
            % Make sure the IndexSets table is always sorted
            valueSorted = sortrows(value,'SetId','ascend');
            obj.IndexSets = valueSorted;
        end
    end
end
