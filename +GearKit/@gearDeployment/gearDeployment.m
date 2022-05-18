classdef gearDeployment < matlab.mixin.SetGet
    % gearDeployment  The superclass to all gear deployments
    % The GEARDEPLOYMENT class defines basic metadata on a gear deployment
    % and reads it upon construction.
    %
    % gearDeployment Properties:
    %	gearType - Type of gear
    %	cruise - Cruise id of the deployment
    %	gear - Gear id of the deployment
    %	station - Station id of the deployment
    %	areaId - Area or transect id of the deployment
    %   gearId - Id string that uniquely identifies a gearDeploment
    %	longitude - Longitude of the deployment
    %	latitude - Latitude of the deployment
    %	depth - Depth of the deployment
    %	timeDeployment - Time of the deployment
    %	timeRecovery - Time of the recovery
    %	timeOfInterestStart - Time of interest start
    %	timeOfInterestEnd - Time of interest end
    %	calibration - Calibration data
    %	analysis - Data analysis object
    %	dataFolderInfo - Structure that holds metadata on the gear deployment folder
    %	variables - List of variables available for this deployment
    %
    % gearDeployment Methods:
    %	exportData -
    %	plot -
    %	runAnalysis -
    %
    % Copyright (c) 2020-2022 David Clemens (dclemens@geomar.de)
    %

	properties
        data DataKit.dataPool
        HardwareConfiguration GearKit.hardwareConfiguration
        gearType GearKit.gearType = GearKit.gearType.undefined % Type of gear
        cruise = categorical.empty % Cruise id of the deployment
        gear = categorical.empty % Gear id of the deployment
        station = categorical.empty % Station id of the deployment
        areaId = categorical.empty % Area or transect id of the deployment
        longitude = [] % Longitude of the deployment
        latitude = [] % Latitude of the deployment
        depth = [] % Depth of the deployment
        timeDeployment = datetime.empty % Time of the deployment
        timeRecovery = datetime.empty % Time of the recovery
        timeOfInterestStart = datetime.empty % Time of interest start
        timeOfInterestEnd = datetime.empty % Time of interest end
        calibration table = table.empty % Calibration data
        analysis % Data analysis object
        dataFolderInfo	= struct('gearName',   	char.empty,...
                                 'rootFolder',	char.empty,...
                                 'dataFolder', 	char.empty);    % Structure that holds metadata on the gear deployment folder
    end
    properties (Dependent)
        variables % List of variables available for this deployment
        gearId % Id string that uniquely identifies a gearDeploment
    end
    properties (Hidden)
        dataVersion % version of protocol data structure to be used
        SaveFile char = char.empty
        LoadFile char = char.empty
    end
    properties (Constant, Access = 'protected')
        DataStructureVersion = '0.1.0' % version of class property data structure to be used        
    end

	methods
        % CONSTRUCTOR METHOD
        function obj = gearDeployment(path,gearType,varargin)

            obj.gearType   	= gearType;

            obj.data        = DataKit.dataPool();
            
            if isempty(path)
                return
            end

            % extract file metadata
            getGearDeploymentMetadata(obj,path);
            readCalibrationData(obj);
        end
    end

 	% get methods
 	methods
      	function variables = get.variables(obj)
            dataPoolInfo	= obj.data.info;
            mask            = dataPoolInfo{:,'Type'} == 'Dependent';
            dataPoolInfo   	= dataPoolInfo(mask,:);
            [~,uIdxa,uIdxb] = unique(dataPoolInfo(:,{'Id'}),'rows');
            variables       = dataPoolInfo(uIdxa,:);

            % create dependent variable index touples (dpIdx,dvIdx)
            subs            = [[uIdxb,ones(size(uIdxb))];[uIdxb,2.*ones(size(uIdxb))]];
            val             = cat(1,dataPoolInfo{:,'DataPoolIndex'},dataPoolInfo{:,'VariableIndex'});
            tmp             = accumarray(subs,val,[size(variables,1),2],@(x) {x},{[]});
            variables.Index = arrayfun(@(r) cat(2,tmp{r,1},tmp{r,2}),1:size(tmp,1),'un',0)';

            % create independent variableindex touples (dpIdx,ivIdx)
            variables{:,'IndependentVariable'}     = {{}};
            for vv = 1:size(variables,1)
                maskDataPoolInfo    = uIdxb == vv;
                variables{vv,'IndependentVariable'} = {dataPoolInfo{maskDataPoolInfo,'IndependentVariable'}};
            end

            variables.Name  = categorical(cellstr(variables.Variable));
            variables       = variables(:,{'Name','Id','Type','Unit','Index','IndependentVariable'});
        end
        function gearId = get.gearId(obj)
            gearId = strjoin(cat(1,cellstr(obj.cruise),cellstr(obj.gear)),'_');
            if isempty(gearId)
                gearId = ['Generic',char(obj.gearType),'Deployment'];
            end
        end
    end

	% methods in seperate files
    methods (Access = public)
        data = fetchData(obj,variable,varargin)
        varargout = exportData(obj,parameter,filename,varargin)
        varargout = plot(obj,varargin)
        varargout = plotCalibrations(obj)
        varargout = markQualityFlags(obj)
        filenames = save(obj,varargin)
        s = saveobj(obj)
        obj = reloadobj(obj,s)
        update(obj)
        varargout = sort(obj,varargin)
    end
    methods (Static)
        obj = load(varargin)
    end
    methods (Access = protected)
        getGearDeploymentMetadata(obj,pathName)
        assignMeasuringDeviceMountingData(obj)
        readAuxillaryMeasuringDevices(obj)
        readCalibrationData(obj)
        calibrateMeasuringDevices(obj)
        readAnalyticalSamples(obj)
    end
    methods (Access = protected, Abstract)
        readInternalMeasuringDevices(obj)
        determineHardwareConfiguration(obj)
    end
    methods (Abstract)
        runAnalysis(obj)
    end
end
