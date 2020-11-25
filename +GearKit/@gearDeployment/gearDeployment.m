classdef gearDeployment
% GEARDEPLOYMENT The superclass to all gear deployments
%	The GEARDEPLOYMENT class defines basic metadata on a gear deployment
%	and reads it upon construction.
%
% GEARDEPLOYMENT Properties:
%	sensors - 
%	analyticalSamples - 
%	gearType - 
%	cruise - 
%	gear - 
%	station - 
%	areaId - 
%	longitude - 
%	latitude - 
%	depth - 
%	timeDeployment - 
%	timeRecovery - 
%	timeOfInterestStart - 
%	timeOfInterestEnd - 
%	calibration - 
%	analysis - 
%	dataFolderInfo - 
%	parameters - 
%	hasSensorData - 
%	hasAnalyticalData - 
%	validGearTypes - 
%	debugger - 
%	dataVersion - 
%
% GEARDEPLOYMENT Methods:
%	gearDeployment - Constructs an gearDeployment instance
%	exportData - 
%	plot - 
%	runAnalysis - 
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

	properties
        data DataKit.dataPool = DataKit.dataPool()
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
                                 'dataFolder', 	char.empty,...
                                 'saveFile',    char.empty);    % Structure that holds metadata on the gear deployment folder
    end
    properties (Dependent)
        variables
%         hasSensorData logical
%         hasAnalyticalData logical
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
            
            obj.gearType        = gearType;
            
            % extract file metadata
            obj	= getGearDeploymentMetadata(obj,path);
            obj = readCalibrationData(obj);
        end
        
        % get methods
      	function variables = get.variables(obj)
            dataPoolInfo	= obj.data.info;
            mask            = dataPoolInfo{:,'Type'} == 'Dependant';
            dataPoolInfo   	= dataPoolInfo(mask,:);
            [~,uIdxa,uIdxb] = unique(dataPoolInfo(:,{'Id'}),'rows');
            variables       = dataPoolInfo(uIdxa,:);
            subs            = [[uIdxb,ones(size(uIdxb))];[uIdxb,2.*ones(size(uIdxb))]];
            val             = cat(1,dataPoolInfo{:,'DataPoolIndex'},dataPoolInfo{:,'VariableIndex'});
            tmp             = accumarray(subs,val,[size(variables,1),2],@(x) {x},{[]});
            variables.Index = arrayfun(@(r) cat(2,tmp{r,1},tmp{r,2}),1:size(tmp,1),'un',0)';
            variables.Name  = categorical(cellstr(variables.Variable));
            variables       = variables(:,{'Name','Id','Type','Unit','Index'});
        end
    end
    
	% methods in seperate files
    methods (Access = public)
        data = getData(obj,variable,varargin)
        varargout = exportData(obj,parameter,filename,varargin)
        varargout = plot(obj,varargin)
        varargout = plotCalibrations(obj)
        obj = markQualityFlags(obj)
        obj = loadobj(obj)
        obj = saveobj(obj)
        obj = update(obj)
    end
    methods (Access = protected)
        obj	= getGearDeploymentMetadata(obj,pathName)
        obj	= assignMeasuringDeviceMountingData(obj)
        obj	= readAuxillarySensors(obj)
        obj = readCalibrationData(obj)
        obj = calibrateMeasuringDevices(obj)
        obj = readAnalyticalSamples(obj)
    end
    methods (Access = protected, Static)
        [time,data,meta,outlier] = initializeGetDataOutputs()
    end
    methods (Access = protected, Abstract)
        internalSensors = readInternalSensors(obj)
    end
    methods (Abstract) 
        obj = runAnalysis(obj)
    end
end