classdef gearDeployment
% GEARDEPLOYMENT The superclass to all gear deployments
%   The GEARDEPLOYMENT class defines basic metadata on a gear deployment
%   and reads it upon construction.
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

	properties
        sensors GearKit.sensor = GearKit.sensor.empty % Sensors
        analyticalSamples % Analytical sample results
        gearType = char.empty % Type of gear
        cruise = categorical.empty % Cruise id of the deployment
        gear = categorical.empty % Gear id of the deployment
        station = categorical.empty % Station of the deployment
        areaId = categorical.empty % Area or transect id of the deployment
        longitude = [] % Longitude of the deployment
        latitude = [] % Latitude of the deployment
        depth = [] % Depth of the deployment
        timeDeployment = datetime.empty % Time of the deployment
        timeRecovery = datetime.empty % Time of the recovery
        timeOfInterestStart = datetime.empty % Time of interest start
        timeOfInterestEnd = datetime.empty % Time of interest end
        calibration table = table.empty % calibration data
        analysis % Data analysis object
        dataFolderInfo	= struct('gearName',   	char.empty,...
                                 'rootFolder',	char.empty,...
                                 'dataFolder', 	char.empty);    % Structure that holds metadata on the gear deployment folder
    end
    properties (Dependent)
        parameters
        hasSensorData logical
        hasAnalyticalData logical
    end
    properties (Hidden, Access = private, Constant)
        validGearTypes = {'BIGO','EC'} % List of valid gear types
    end
    properties (Hidden)
        debugger DebuggerKit.Debugger % Debugging object
        dataVersion % version of data structure to be used
    end
    
	methods
        % CONSTRUCTOR METHOD
        function obj = gearDeployment(path,gearType,varargin)
            
            % parse Name-Value pairs
            optionName          = {'DebugLevel'}; % valid options (Name)
            optionDefaultValue  = {'Info'}; % default value (Value)
            [debugLevel]     	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
            
            obj.debugger        = DebuggerKit.Debugger(...
                                    'DebugLevel',       debugLevel);
            
            obj.gearType    = gearType;
            
            % extract file metadata
            obj	= getGearDeploymentMetadata(obj,path);
            obj = readCalibrationData(obj);
        end
        
        % get methods
      	function parameters = get.parameters(obj)
            [uS,~,uSInd]   	= unique(cat(2,obj.sensors.dataParameters)','stable');
            uA              = unique(obj.analyticalSamples{:,'ParameterId'},'stable');
            parameters     	= table(uS,true(size(uS)),false(size(uS)),'VariableNames',{'ParameterId','InSensorData','InAnalyticalSampleData'});
         	parameters     	= [parameters;table(uA,false(size(uA)),true(size(uA)),'VariableNames',{'ParameterId','InSensorData','InAnalyticalSampleData'})];

            [~,info]                = DataKit.validateParameterId(parameters{:,'ParameterId'});
            parameters.Parameter	= info.Parameter;
            
            cs          = cumsum(arrayfun(@(di) di.nParameters,[obj.sensors.dataInfo]));
            s           = arrayfun(@(di) 1:di.nParameters,[obj.sensors.dataInfo],'un',0);
      
            index       = [sum((1:numel(uSInd))' > cs,2) + 1, ...
                            uSInd,...
                            [s{:}]'];
            
            index                       = sortrows(index,2);
            parameters.SensorIndex(1:size(uS,1))	= accumarray(index(:,2),index(:,1),[],@(x) {x});
            parameters.ParameterIndex(1:size(uS,1))	= accumarray(index(:,2),index(:,3),[],@(x) {x});
            parameters.nParameter                   = cellfun(@numel,parameters{:,'ParameterIndex'});
            
            im = uA == uS';
            if any(im(:))
                error('TODO')
            end
        end
        function hasSensorData = get.hasSensorData(obj)
            hasSensorData       = ~isempty(obj.sensors);
        end
        function hasAnalyticalData = get.hasAnalyticalData(obj)
            hasAnalyticalData   = ~isempty(obj.analyticalSamples);
        end
    end
    
	% methods in seperate files
    methods (Access = public)
        [time,data,varargout]   = getSensorData(obj,parameter,varargin)
        varargout               = exportData(obj,parameter,filename,varargin)
        varargout               = plot(obj,varargin)
    end
    methods (Access = protected)
        obj	= getGearDeploymentMetadata(obj,pathName)
        obj	= assignSensorMountingData(obj)
        obj	= readAuxillarySensors(obj)
        obj = readCalibrationData(obj)
        obj = calibrateSensors(obj)
        obj = readAnalyticalSamples(obj)
    end
    methods (Access = protected, Static)
        [time,data,meta] = initializeGetDataOutputs()
    end
    methods (Access = protected, Abstract)
        internalSensors = readInternalSensors(obj)
    end
    methods (Abstract) 
        obj = runAnalysis(obj)
    end
end