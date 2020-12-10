classdef measuringDeviceType
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
    methods (Static)
        list = listAllMeasuringDeviceType()
    end
end