classdef bigoSalinityInjectionAnalysis < AnalysisKit.analysis
% BIGOSALINITYINJECTIONANALYSIS


    properties (SetObservable, AbortSet)
        Name char = 'BigoSalinityInjection' % Analysis name
        Type char = 'Injection' % Analysis type
        Parent = GearKit.bigoDeployment % Parent bigoDeployment instance
        DeviceDomains GearKit.deviceDomain % The device domain(s) to be analysed

        TimeUnit (1,:) char = 'h' % The relative time unit
    end

    % Frontend
    properties (Dependent)
        % Stack independent
        
        % Stack depth 1 (Data)
        Time double % Time
        RawConductivity double % Raw conductivity
        SalinityRaw double % Raw salinity
        TemperatureRaw double % Raw temperature
        
        Data double % Raw data
        Pressure double % Pressure (dbar)
        
        DataVariables DataKit.Metadata.variable
        DataDeviceDomains GearKit.deviceDomain
        DataOriginTime datetime % The absolute time origin

        % Stack depth 2 (Exclusion evaluation)
        Exclude logical % Exclusions

        % Stack depth 3 (Convert to TEOS-10)
        SalinityAbsolute double % Absolute salinity (g kg-1)
        TemperatureConservative double % Conservative temperature (°C)

        % Stack depth 4 (QC)

        % Stack depth 5 (Fluxes)
    end

    % Backend
    properties (Access = 'private')
        % Stack independent
        
        % Stack depth 1 (Data)
        Time_ datetime
        RawConductivity_ double
        SalinityRaw_ double
        TemperatureRaw_ double
        Data_ double
        Pressure_ double
        
        DataVariables_ DataKit.Metadata.variable
        DataDeviceDomains_ GearKit.deviceDomain
        DataOriginTime_ datetime

        % Stack depth 2 (Exclusion evaluation)
        Exclude_ logical

        % Stack depth 3 (Convert to TEOS-10)
        SalinityAbsolute_ double
        TemperatureConservative_ double

        % Stack depth 4 (QC)

        % Stack depth 5 (Fluxes)
    end

  	properties (Hidden, Dependent)
        UpdateStack double
    end
    properties (Access = 'private')
        UpdateStack_ (5,1) double = 2.*ones(5,1) % Initialize as update required
    end
    properties
        DataReferenceVolume double
        FlagDataset DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.bigoSalinityInjectionAnalysisDatasetFlag')
        FlagData DataKit.bitflag = DataKit.bitflag('AnalysisKit.Metadata.bigoSalinityInjectionAnalysisDataFlag')
    end
    properties %(Hidden)
        PoolIndex double % Order: conductivity, salinity, temperature
        VariableIndex double % Order: conductivity, salinity, temperature
        TimeUnitFunction function_handle = @hours % Note: This must correspond to the TimeUnit property, as TimeUnit has the property attribute 'AbortSet' set.
        TimeVariable DataKit.Metadata.variable = DataKit.Metadata.variable.Time
    end
    properties (Dependent)
        NVariables double
        NDeviceDomains double
        IncubationInterval double
        SalinityPractical double % Practical salinity
        Density double % In-situ density (kg m-3)
        SalinityAbsolutePerVolume double % Absolute salinity (g L-1)
    end

    methods
        function obj = bigoSalinityInjectionAnalysis(varargin)
        
        %   Syntax
        %     obj = BIGOSALINITYINJECTIONANALYSIS()
        %     obj = BIGOSALINITYINJECTIONANALYSIS(bigoDeployment)
        %     obj = BIGOSALINITYINJECTIONANALYSIS(__,Name,Value)

            import DebuggerKit.Debugger.printDebugMessage
            import internal.stats.parseArgs

            defaultBigoDeployment	= GearKit.bigoDeployment();
            if nargin == 0
                bigoDeployment      = defaultBigoDeployment;
            elseif nargin >= 1
                bigoDeployment      = varargin{1};
                varargin(1)         = [];
            end

            % Input checks
            if ~isa(bigoDeployment,'GearKit.bigoDeployment')
                printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:bigoFluxAnalysis:invalidType',...
                    'Error','The first input has to be a GearKit.bigoDeployment instance.')
            end
            if ~isscalar(bigoDeployment)
                printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:bigoFluxAnalysis:nonScalarContext',...
                    'Error','The analysis can only be run on a single bigoDeployment instance.')
            end

            % Parse Name-Value pairs
            optionName          = {'DeviceDomains','TimeUnit'}; % valid options (Name)
            optionDefaultValue  = {GearKit.deviceDomain.fromProperty('Abbreviation',{'Ch1';'Ch2'}),'h'}; % default value (Value)
            [deviceDomains,...
             timeUnit] = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            % Call superclass constructor
            obj = obj@AnalysisKit.analysis();

            % Input validation

            % Add property listeners
            addlistener(obj,'TimeUnit','PostSet',@AnalysisKit.bigoSalinityInjectionAnalysis.handlePropertyChangeEvents);
            obj.TimeUnit          	= timeUnit;

            % Populate properties
            % Update stack depth 1
            addlistener(obj,'Parent','PostSet',@AnalysisKit.bigoSalinityInjectionAnalysis.handlePropertyChangeEvents);
            addlistener(obj,'DeviceDomains','PostSet',@AnalysisKit.bigoSalinityInjectionAnalysis.handlePropertyChangeEvents);
            validateattributes(bigoDeployment,{'GearKit.bigoDeployment'},{});
            obj.Parent            	= bigoDeployment;
            obj.DeviceDomains      	= deviceDomains;

            % Update stack depth 2

            % Update stack depth 3
        end
    end

    % Methods in other files
    methods
        checkUpdateStack(obj,stackDepth) % make private
        varargout = plot(obj,varargin)
        varargout = plotOverview(obj,axesProperties)
    end

  	% Get methods
    methods
        function nVariables = get.NVariables(obj)
            nVariables = numel(obj.DataVariables);
        end
        function nDeviceDomains = get.NDeviceDomains(obj)
            nDeviceDomains = numel(obj.DeviceDomains);
        end
        function incubationInterval = get.IncubationInterval(obj)
            incubationInterval = [0, obj.TimeUnitFunction(diff(obj.Parent.HardwareConfiguration.DeviceDomainMetadata{1,{'ExperimentStart','ExperimentEnd'}}))];
        end
        function salinityPractical = get.SalinityPractical(obj)
            salinityPractical = gsw_SP_from_C(obj.RawConductivity,obj.TemperatureRaw,obj.Pressure); % PSU
        end
        function density = get.Density(obj)
            density = gsw_rho(obj.SalinityAbsolute,obj.TemperatureConservative,obj.Pressure); % kg m-3
        end
        function salinityAbsolutePerVolume = get.SalinityAbsolutePerVolume(obj)
            salinityAbsolutePerVolume = obj.SalinityAbsolute./gsw_specvol(obj.SalinityAbsolute,obj.TemperatureConservative,obj.Pressure).*1e-3; % g L-1
        end
    end

    % Set methods
    methods
        
    end

    % Frontend/Backend interface: Get methods
    methods
        % Stack independent
        function updateStack = get.UpdateStack(obj)
            updateStack = obj.UpdateStack_;
        end

        % Stack depth 1
        function time = get.Time(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            time = obj.TimeUnitFunction(obj.Time_ - repmat(obj.DataOriginTime,size(obj.Time_,1),1)); % Return time depending on
        end
        function rawConductivity = get.RawConductivity(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            rawConductivity = obj.RawConductivity_;
        end
        function salinityRaw = get.SalinityRaw(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            salinityRaw = obj.SalinityRaw_;
        end
        function temperatureRaw = get.TemperatureRaw(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            temperatureRaw = obj.TemperatureRaw_;
        end
        function data = get.Data(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            data = obj.Data_;
        end
        function pressure = get.Pressure(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            pressure = obj.Pressure_;
        end

        function dataVariables = get.DataVariables(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            dataVariables = obj.DataVariables_;
        end
        function dataDeviceDomains = get.DataDeviceDomains(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            dataDeviceDomains = obj.DataDeviceDomains_;
        end
        function dataOriginTime = get.DataOriginTime(obj)
            stackDepth = 1;
            obj.checkUpdateStack(stackDepth)
            dataOriginTime = obj.DataOriginTime_;
        end
        
        % Stack depth 2
        function exclude = get.Exclude(obj)
            stackDepth = 2;
            obj.checkUpdateStack(stackDepth)
            exclude = obj.Exclude_;
        end

        % Stack depth 3
        function salinityAbsolute = get.SalinityAbsolute(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            salinityAbsolute = obj.SalinityAbsolute_;
        end
        function temperatureConservative = get.TemperatureConservative(obj)
            stackDepth = 3;
            obj.checkUpdateStack(stackDepth)
            temperatureConservative = obj.TemperatureConservative_;
        end

        % Stack depth 4

        % Stack depth 5
    end

    % Frontend/Backend interface: Set methods
    methods
        % If frontend properties are set, update the backend and set any necessary
        % flags
        
        % Stack independent
        function obj = set.UpdateStack(obj,value)
            if ~isequal(obj.UpdateStack,value)
                % If the UpdateStack is set (modified), set all stackDepths below the first change to 'UpdateRequired'
                updateStackDepth           	= find(diff(cat(2,obj.UpdateStack_,value),1,2) == 2,1); % Status changes from Updated to UpdateRequired
                value(updateStackDepth:end) = 2; % Set all stati downstream to UpdateRequired
                obj.UpdateStack_            = value;
            end
        end
        
        % Stack depth 1
        function obj = set.Time(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Time_                   = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.RawConductivity(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.RawConductivity_    	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.SalinityRaw(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.SalinityRaw_            = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.TemperatureRaw(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.TemperatureRaw_         = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.Data(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Data_                   = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.Pressure(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Pressure_               = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        
        function obj = set.DataVariables(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.DataVariables_          = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.DataDeviceDomains(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.DataDeviceDomains_   	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.DataOriginTime(obj,value)
            stackDepth                  = 1;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.DataOriginTime_      	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        
        % Stack depth 2
        function obj = set.Exclude(obj,value)
            stackDepth                  = 2;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.Exclude_                = value;
            obj.setUpdateStackToUpdated(stackDepth)
        end

        % Stack depth 3
        function obj = set.SalinityAbsolute(obj,value)
            stackDepth                  = 3;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.SalinityAbsolute_    	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end
        function obj = set.TemperatureConservative(obj,value)
            stackDepth                  = 3;
            obj.setUpdateStackToUpdating(stackDepth)
            obj.TemperatureConservative_	= value;
            obj.setUpdateStackToUpdated(stackDepth)
        end

        % Stack depth 4
        
        % Stack depth 5
    end

    % Methods called from checkUpdateStack
    methods (Access = private)
        % Stack depth 1
        setVariables(obj)
        setRawData(obj)

        % Stack depth 2
       	setExclusions(obj)

        % Stack depth 3
        convertToTEOS10(obj)
        
        % Stack depth 4

        % Stack depth 5
    end

    % Event handler methods
    methods (Access = private)
        setRelativeTimeFunction(obj)
    end
    methods (Static)
        function handlePropertyChangeEvents(src,evnt)
            switch src.Name
                case 'Parent'
                    % The parent bigoDeployment object has been set. The raw data needs to be
                    % extracted again.
                    stackDepth  = 1;
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)
                case 'DeviceDomains'
                    % The device domains have been set. The raw data needs to be extracted
                    % again.
                    stackDepth  = 1;
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)
                case 'TimeUnit'
                    % The fit & flux are normalized to the time unit. The fits need to be
                    % recalculated.
                    stackDepth  = 3;
                    setRelativeTimeFunction(evnt.AffectedObject)
                    evnt.AffectedObject.setUpdateStackToUpdateRequired(stackDepth)
            end
        end
    end
end
