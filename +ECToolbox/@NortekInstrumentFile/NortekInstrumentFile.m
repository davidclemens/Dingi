classdef (ConstructOnLoad) NortekInstrumentFile
% NORTEKINSTRUMENTFILE Superclass to all Nortek instrument files
%   The NORTEKINSTRUMENTFILE class indexes a binary Nortek instrument file  
%   and reads the general data structures Harware, Head and User 
%   Configuration that are common to all Nortek binary files.
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
    
	properties
        fileInfo        = struct('name',    '',...
                                 'ext',     '',...
                                 'bytes',   NaN,...
                                 'bitOrder','l',...
                                 'path',    '',...
                                 'full',    ''); % Structure that holds metadata on the Nortek instrument file
        HardwareConfiguration ECToolbox.HardwareConfiguration % Hardware configuration object
        HeadConfiguration ECToolbox.HeadConfiguration % Head configuration object
        UserConfiguration ECToolbox.UserConfiguration % User configuration object
    end
    properties (Abstract, Constant)
        instrumentName % Name of the Nortek instrument (Vector)
        instrumentType % Type of Nortek instrument (current meter, current profiler or velocitometer)
    end
    properties (Abstract, Constant, Hidden)
        instrumentFileExtension % Expected file extension
    end
    properties (Abstract, Hidden)
        dataMetadata
        timeMetadata
    end
    properties (Hidden)
        debugger DebuggerKit.Debugger % debugging object
    end
    properties (Transient)
        fileIndex struct % File index to quickly access all binary data structures
    end
    properties (Hidden, Transient)
      	rawData(:,1) uint8 {mustBeInteger, mustBeNonnegative,mustBeLessThan(rawData,256)} % Raw binary data of the Nortek instrument file
    end
    
	methods
        % CONSTRUCTOR METHOD
        function obj = NortekInstrumentFile(fullFilename,varargin)
        % NORTEKINSTRUMENTFILE Constructs a Nortek instrument object.
        % Create a NortekInstrumentFile object that reads a Nortek instrument file.
        %
        % Syntax
        %   NortekInstrumentFile = NORTEKINSTRUMENTFILE(filename)
        %   NortekInstrumentFile = NORTEKINSTRUMENTFILE(__,Name,Value)
        %
        % Description
        %   NortekInstrumentFile = NORTEKINSTRUMENTFILE(filename) reads the Nortek 
        %        instrument file specified in filename and returns a 
        %        NortekInstrumentFile object.
        %
        %   NortekInstrumentFile = NORTEKINSTRUMENTFILE(__,Name,Value) 
        %       specifies additional parameters for the NortekInstrumentFile using 
        %       one or more name-value pair arguments as listed below.
        %
        % Example(s) 
        %
        %
        % Input Arguments
        %   filename - full file name to the Nortek instrument file
        %       The full filename to the Nortek instrument file to be read.
        %
        %
        % Name-Value Pair Arguments
        %   DebugLevel - Level of debug information
        %       'Info' (default) | 'Error' | 'Warning' | 'Verbose'
        %           Sets the debug level which controls the level of information
        %           that is output to the command window.
        %   Reindex - Reindex instrument file
        %       false (default) | true
        %           Set to true if the file should be reindexed.
        %
        % 
        % See also
        %
        % Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
            
            % parse Name-Value pairs
            optionName          = {'DebugLevel','Reindex'}; % valid options (Name)
            optionDefaultValue  = {'Info',false}; % default value (Value)
            [debugLevel,...
             reindex]           = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            
            obj.debugger        = DebuggerKit.Debugger(...
                                    'DebugLevel',       debugLevel);
            
            %if nargin() == 0 && ~isempty(obj.fileInfo.full)
                % the constructor is called without arguments when the
                % object
                
            % check if file extension is the expected one
            if isempty(regexpi(fullFilename,['\',obj.instrumentFileExtension,'$']))
                error('The input file is not a %s file.',obj.instrumentFileExtension)
            end
            % check if filename is a char
            if ~ischar(fullFilename)
                error('Filename must be a char. It was %s instead.',class(fullFilename))
            end
            
            % extract file metadata
            [obj.fileInfo.path,...
             obj.fileInfo.name,...
             obj.fileInfo.ext]      = fileparts(fullFilename);
            dirStruct               = dir(fullFilename);
            obj.fileInfo.bytes      = dirStruct.bytes;
            obj.fileInfo.full       = fullFilename;
            
            % read raw data
            obj.rawData                 = obj.readRawData();
            
            % create fileIndex & test checksums
            obj.fileIndex               = obj.createFileIndex(...
                                            'Reindex',  reindex);
            
            % read headers
            obj.HardwareConfiguration   = ECToolbox.HardwareConfiguration(obj);
            obj.HeadConfiguration       = ECToolbox.HeadConfiguration(obj);
            obj.UserConfiguration       = ECToolbox.UserConfiguration(obj);
        end
        
        % METHODS (in seperate files)
        sobj            = saveobj(obj)
        rawData         = readRawData(obj);
        ind             = createFileIndex(obj,varargin)
        data            = getDataArray(obj,structId,offset,type)
        [timeseriesCollectionSlow,...
         timeseriesCollectionRapid]	= makeTimeseriesCollection(obj)
        timeseries      = makeTimeseries(obj,parameterName)
        varargout       = plot(obj,varargin)
    end
    
    methods (Static)
        % METHODS (in seperate files)
        obj         = loadobj(sobj)
        meta        = getNortekFileStructureMetadata()
    end    
end