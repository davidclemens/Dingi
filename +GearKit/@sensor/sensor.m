classdef sensor
% SENSOR Represents a real-world sensor
%   The SENSOR class represents a real-world sensor that is attached to the
%   gear in question. It has methods to read the sensor data from the
%   respective data files. One sensor can have multiple data parameters
%   (e.g. an optode holds oxygen concentration and temperature).
%
% Copyright 2020 David Clemens (dclemens@geomar.de)
    properties
        id char = ''; % sensor id (unique to a sensor type, e.g. BigoOptode)
        name char = ''; % custom sensor name
        type char = ''; % sensor type (e.g. optode)
        group char = ''; % sensor group
        serialNumber char = ''; % sensor serial number
        mountingLocation char = ''; % sensor mounting location within the gear (e.g. Ch1, LegA, Sparn,...)
        mountingDomain char = ''; % sensor mounting domain (e.g. Ch1, BW, PW,...)
        dataPath char = '' % path to the raw data file(s)
        
        time double = []; % data timeline as datenum
        depth double = []; % data depth
        data double = []; % data
        dataRaw double = []; % raw data
        timeInfo GearKit.timeMetadata = GearKit.timeMetadata() % metadata on the timeline
        dataInfo GearKit.dataMetadata = GearKit.dataMetadata() % metadata on the data
    end
    properties (Dependent)
        dataParameters % list of all available parameters
        dataParametersRaw % list of all available parameters including raw uncalibrated parameters
    end
    properties (Dependent, Hidden)
        timeDateTime
    end
    properties (Hidden, Access = private, Constant)
        validIds = {'BigoOptode','BigoConductivity','BigoVoltage','HoboLightLogger','SeabirdCTD',   'O2Logger'} % list of valid sensor ids
        validExt = {'txt',       'txt',             'txt',        'txt',            'cnv',          'txt'} % list of valid sensor file extensions corresponding to the sensor ids
    end
    properties (Hidden)
        debugger DebuggerKit.Debugger % Debugging object
    end
    
    methods
        function obj = sensor(id,dataPath,varargin)   
        % SENSOR Constructs a sensor object.
        % Create a SENSOR object.
        %
        % Syntax
        %   Sensor = SENSOR(id,dataPath)
        %
        % Description
        %   Sensor = SENSOR(id,dataPath) reads the data of a sensor with the
        %       sensor id id specified in dataPath and returns a Sensor object.
        %
        % Example(s)
        %   Sensor = SENSOR('BigoOptode','./BIGO-I-01')
        %   Sensor = SENSOR('HoboLightLogger','./BIGO-I-01/AuxSensor_Hobo light logger/BIGO1-01_A_10070102.txt')
        %
        %
        % Input Arguments
        %   id - id of the sensor
        %       valid ids are: 'BigoOptode', 'BigoConductity', etc.. For a full
        %       list type GearKit.sensor
        %
        %
        % Name-Value Pair Arguments
        %
        % 
        % See also
        %
        % Copyright 2020 David Clemens (dclemens@geomar.de)
            
            % parse Name-Value pairs
            optionName          = {'DebugLevel'}; % valid options (Name)
            optionDefaultValue  = {'Info'}; % default value (Value)
            [debugLevel]     	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            
            obj.debugger        = DebuggerKit.Debugger(...
                                    'DebugLevel',       debugLevel);
            
            obj.id          = id;
            obj.dataPath    = dataPath;
            obj             = readData(obj);
%             obj             = calibrateData(obj);
        end
    end
    methods
        % methods in seperate files
        obj = readData(obj)
        obj = calibrateData(obj)
        obj = readBigoOptode(obj)
        obj = readBigoConductivity(obj)
        obj = readBigoVoltage(obj)
        obj = readHoboLightLogger(obj)
        obj = readSBECTD(obj)
      	obj = readO2Logger(obj)
        
        [t,d]   = gd(obj,parameter,varargin)
        
        % overloaded methods
        s = plus(obj1,obj2)
        
        % get methods
        function dataParameters = get.dataParameters(obj)
            dataParameters    	= obj.dataInfo.id;
%             dataParameters  	= unique(dataParameters,'stable');
        end
        function dataParametersRaw = get.dataParametersRaw(obj)
          	dataParametersRaw	= obj.dataInfo.idRaw;
%             dataParametersRaw	= unique(dataParametersRaw,'stable');
        end
        function data = get.data(obj)
            data    = obj.data;
        end
        function timeDateTime = get.timeDateTime(obj)
            timeDateTime = datetime(obj.time,'ConvertFrom','datenum');
        end
        
        % set methods
        function obj = set.data(obj,value)
            
            [obj.dataInfo.nSamples,obj.dataInfo.nParameters]	= size(value);
            
            % only if data is set the first time
            if isempty(obj.data)
%                 obj.dataInfo	= setDefault(obj.dataInfo);
            else
                if size(obj.data) ~= size(value)
                    error('GearKit:sensor:changeDataShapeNotAllowed',...
                        'It is not allowed to change the shape of the sensor data after its creation.')
                end
            end
            
            % now set the data
            obj.data	= value;
        end
        function obj = set.time(obj,value)
            obj.time    = value;
            intervals   = diff(value);
            obj.timeInfo.sampleInterval	= mean(seconds(intervals));
        end
        
        %custom subasign/subrefs
        %{
        function n = numArgumentsFromSubscript(obj,~,~)
        % overloading numArgumentsFromSubscript for the use in subsref and
        % subasign
            n = numel(obj);
        end
        function varargout = subsref(obj,s)
        % overloading subsref
            switch s(1).type
                case '{}'
                    nObj        = numel(obj);
                    varargout   = cell(1,nObj);
                    for ii = 1:nObj
                        [im,imInd]	= ismember(s.subs,obj(ii).dataInfo.name);
                        if any(~im)
                            error('sensor:subsref',...
                                  'The sensor ''%s'' holds no data called ''%s''\nAvailable data names are: %s.',obj.name,s.subs{find(~im,1)},strjoin(obj.dataInfo.name,', '))
                        else
                            varargout{ii}    = obj(ii).data(:,imInd);
                        end
                    end
                otherwise
                 	varargout	= {builtin('subsref',obj,s)};
            end
        end        
        function obj = subsasgn(obj,s,varargin)
        % overloading subasign
            switch s(1).type
                case '.'
                    obj = builtin('subsasgn',obj,s,varargin{:});
                case '()'
                    obj = builtin('subsasgn',obj,s,varargin{:});
                otherwise
                    error('sensor:subasign',...
                          'subasign not possible.')
            end
        end
        %}
    end
end