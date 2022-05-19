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
        %       'single' (default) | 'double' | 'int8' | 'uint8' | 'int16' | 'uint16' | 'int32' | 'uint32' | 'int64' | 'uint64'
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
        data = getData(obj,setId,variableId,groupMode)
    end
    methods (Access = 'protected')
        setType(obj,type)
        length = getSetLength(obj,setId)
        validateSetId(obj,setId)
        validateVariableId(obj,setId,variableId)
        setId = getNewSetId(obj)
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
    end
end
