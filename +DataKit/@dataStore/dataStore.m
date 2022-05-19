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
        function obj = dataStore()
            
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
