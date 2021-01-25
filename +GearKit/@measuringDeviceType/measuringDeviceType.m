classdef measuringDeviceType < DataKit.enum
    enumeration
        undefined
        BigoOptode
        BigoConductivityCell
        BigoSyringeSampler
        BigoCapillarySampler
        BigoInjector
        BigoNiskinBottle
        BigoPushCore
        BigoVoltage
        HoboLightLogger
        SeabirdCTD
        NortekVector
        O2Logger
        PyrosciencePico
    end
    properties (SetAccess = 'immutable')
        
    end
    methods (Static)
        L = listMembers()
        obj = fromProperty(propertyname,value)
    end
end