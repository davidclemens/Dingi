classdef dataStore < handle
    
    properties
        Data
        Type
        IndexVariables table = table([],[],[],[],'VariableNames',{'SetId','VariableId','Start','End'})
        IndexSets table = table([],[],[],'VariableNames',{'SetId','Length','NVariables'})
    end
    properties (Dependent)
        NSamples
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
    methods (Access = 'private')
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
    end
end