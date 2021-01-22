classdef VectorProbeCheckData < ECToolbox.NortekDataStructure
% PROBECHECKDATA A NortekDataStructure for Vector and Vectrino.
%   The PROBECHECKDATA class interprets and holds the probe check data of
%   Vector and Vectrino instruments
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

    properties
        nSamplesPerBeam % Number of samples per beam
        fistSampleNumber % First sample number
        amplitude % Amplitudes for all beams and cells
    end
    properties (Hidden)
        structureId = 7 % Structure Id
    end
    
	methods
        function obj = VectorProbeCheckData(NortekInstFileObj)      
        
            % call superclass constructor
            obj                         = obj@ECToolbox.NortekDataStructure(NortekInstFileObj);
            
            % return if data structure is not found in file
            if isempty(obj.structureStart)
                return
            end
            
            % read structure content
            obj.nSamplesPerBeam         = ECToolbox.bytecast(obj.structureBinaryData(5:6),'L','uint16');
            obj.fistSampleNumber        = ECToolbox.bytecast(obj.structureBinaryData(7:8),'L','uint16');
            nBytes                      = obj.nSamplesPerBeam*NortekInstFileObj.HeadConfiguration.nBeams;
          	obj.amplitude               = reshape(ECToolbox.bytecast(obj.structureBinaryData(9:9 + nBytes - 1),'L','uint8'),[],NortekInstFileObj.HeadConfiguration.nBeams); 
        end
    end
end