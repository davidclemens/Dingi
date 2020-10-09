classdef timeMetadata
    properties
        name char = ''
        timeZone char = ''
        sampleInterval = NaN
        sampleFrequency = NaN
    end
    
    methods
        function sampleFrequency = get.sampleFrequency(obj)
            sampleFrequency = 1/obj.sampleInterval;            
        end
    end
end