classdef NortekDataStructure
% NORTEKDATASTRUCTURE Superclass to all binary data structures
%   The NORTEKDATASTRUCTURE class has methods to read the binary data.
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

	properties (Hidden)
        structureStart % Start of data structure (bytes)
        structureSize % Size of data structure (bytes)
        structureBinaryData % Raw binary data of data structure
    end
    properties (Abstract, Hidden)
        structureId % Id of the data structure
    end
    
	methods
        function obj = NortekDataStructure(NortekFileObj)
        % NORTEKDATASTRUCTURE Constructs a NortekDataStructure object.
        % Constructs a NortekDataStructure object that holds its raw binary data
        % and metadata.
        %
        % Syntax
        %   NortekDataStructure = NORTEKDATASTRUCTURE(NortekInstrumentFile)
        %
        % Description
        %   NortekDataStructure = NORTEKDATASTRUCTURE(NortekInstrumentFile) reads a
        %       data structure from the NortekInstrumentFile.
        %
        %
        % Example(s) 
        %
        %
        % Input Arguments
        %   NortekInstrumentFile - an object of class NortekInstrumentFile
        %       The Nortek instrument object.
        %
        %
        % Name-Value Pair Arguments
        %
        % 
        % See also
        %
        % Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
            maskDataStructure       = NortekFileObj.fileIndex.Id == obj.structureId;
            nDataStructures         = sum(maskDataStructure);
            if nDataStructures > 0            
                obj.structureStart      = NortekFileObj.fileIndex.OffsetInBytes(maskDataStructure);
                obj.structureSize       = NortekFileObj.fileIndex.SizeInBytes(maskDataStructure);
                obj.structureBinaryData	= NortekFileObj.rawData(obj.structureStart:obj.structureStart + double(obj.structureSize) - 1);
            else
                if NortekFileObj.debugger.debugLevel >= 'Warning'
                    warning('The file ''%s'' does''t contain the requested NortekDataStructure 0x%s.\n',[NortekFileObj.fileInfo.name,NortekFileObj.fileInfo.ext],dec2hex(obj.structureId,2));
                end
                obj.structureStart      = [];
                obj.structureSize       = uint16([]);
                obj.structureBinaryData = uint8([]);
            end
        end
    end
    
    methods (Static)
        dt	= BCD2datetime(fileID)
    end
end