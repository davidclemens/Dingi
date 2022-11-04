classdef poolInfo < handle
    
    properties %(Hidden)
        Id char = ''
        Parent (1,1)
    end
    properties (SetObservable)
        Variable (1,:) DataKit.Metadata.variable = DataKit.Metadata.variable.empty
        VariableRaw(1,:) DataKit.Metadata.variable = DataKit.Metadata.variable.empty
        VariableType(1,:) DataKit.Metadata.validators.validInfoVariableType = DataKit.Metadata.validators.validInfoVariableType.empty
        VariableCalibrationFunction(1,:) cell = cell.empty
        VariableMeasuringDevice(1,:) GearKit.measuringDevice = GearKit.measuringDevice.empty
    end
    properties
        VariableDescription(1,:) cell = cell.empty
        VariableFactor(1,:) double = []
        VariableOffset(1,:) double = []
        VariableOrigin(1,:) cell = cell.empty
    end
    properties (Dependent)
        VariableId(1,:)
        VariableUnit(1,:) categorical
        VariableRawUnit(1,:) categorical
        VariableIsCalibrated(1,:) logical
    end
    properties (Dependent, Hidden)
        NoIndependentVariable
        VariableReturnDataType
        VariableCount(1,1) double
    end
    
    methods
        function obj = poolInfo(parent,variable,varargin)
            
            import internal.stats.parseArgs
            import UtilityKit.Utilities.arrayhom
            
            uuid    = DataKit.uuid;
            obj.Id = uuid{:};
            
            % Define listeners
            addlistener(obj,'Variable','PostSet',@DataKit.Metadata.poolInfo.handlePropertyChangeEvents);
            
            if nargin == 0
                return
            end
            
            % Cast variable to DataKit.Metadata.variable if necessary
            if ~isa(variable,'DataKit.Metadata.variable')
                variable = DataKit.Metadata.variable(variable);
            end
            
            % Parse Name-Value pairs
            optionName          = {'VariableType','VariableCalibrationFunction','VariableDescription','VariableMeasuringDevice'}; % valid options (Name)
            optionDefaultValue  = {{'undefined'},{@(x) x},{''},GearKit.measuringDevice()}; % default value (Value)
            [variableType,...
             variableCalibrationFunction,...
             variableDescription,...
             variableMeasuringDevice...
                ]               = parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

            if ~isa(variableType,'DataKit.Metadata.validators.validInfoVariableType')
                variableType = DataKit.Metadata.validators.validInfoVariableType(variableType);
            end
            if ischar(variableDescription)
                variableDescription = cellstr(variableDescription);
            end
            if isa(variableCalibrationFunction,'function_handle')
                variableCalibrationFunction = {variableCalibrationFunction};
            end
            
            % Assign parent
            obj.Parent  = parent;
    
            % Homogenize the inputs
            [variable,...
             variableType,...
             variableCalibrationFunction,...
             variableDescription,...
             variableMeasuringDevice ...
                ] = arrayhom(variable,variableType,variableCalibrationFunction,variableDescription,variableMeasuringDevice);
            
            % Reshape vectors to row vectors
            variable                        = reshape(variable,1,[]);
            variableType                  	= reshape(variableType,1,[]);
            variableCalibrationFunction    	= reshape(variableCalibrationFunction,1,[]);
            variableDescription          	= reshape(variableDescription,1,[]);
            variableMeasuringDevice     	= reshape(variableMeasuringDevice,1,[]);
            
            % Assign property values
            obj.Variable                        = variable;
            obj.VariableRaw                     = variable;
            obj.VariableType                    = variableType;
            obj.VariableCalibrationFunction     = variableCalibrationFunction;
            obj.VariableDescription             = variableDescription;
            obj.VariableMeasuringDevice         = variableMeasuringDevice;
            
            sz  = size(variable);
            obj.VariableFactor                  = ones(sz);
            obj.VariableOffset                  = zeros(sz);
            obj.VariableOrigin                  = cell(sz);
        end
    end
    
    methods
        varargout = addVariable(obj,variable,varargin)
        varargout = removeVariable(obj,ind)
        tbl = info2table(obj)
        tf = isequal(objA,objB)
        s = poolInfo2struct(obj)
    end
    methods (Access = private)
        varargout = validatePoolInfoObj(obj)
        varargout = updateVariableRaw(obj)
    end
    
    % Overloaded methods
    methods
        
    end
    
    % Get methods
    methods
        function VariableId = get.VariableId(obj)
            VariableId	= cat(2,obj.Variable.Id);
        end
        function VariableUnit = get.VariableUnit(obj)
            VariableUnit	= cat(2,{obj.Variable.Unit});
        end
        function VariableRawUnit = get.VariableRawUnit(obj)
            VariableRawUnit	= cat(2,{obj.VariableRaw.Unit});
        end
        function VariableCount = get.VariableCount(obj)
            VariableCount = numel(obj.Variable);
        end
        function VariableIsCalibrated = get.VariableIsCalibrated(obj)
            VariableIsCalibrated = ~cellfun(@(f) strcmp(func2str(f),'@(x)x'),obj.VariableCalibrationFunction);
        end
        function NoIndependentVariable = get.NoIndependentVariable(obj)
            NoIndependentVariable = ~any(obj.VariableType == 'Independent');
        end
        function VariableReturnDataType = get.VariableReturnDataType(obj)
            VariableReturnDataType = categorical(cellfun(@class,obj.VariableOrigin,'un',0));
        end
%         function VariableRaw = get.VariableRaw(obj)
%             obj = updateVariableRaw(obj);
%             VariableRaw = obj.VariableRaw;
%         end
    end
    
    % Event handler methods
    methods (Static)
        handlePropertyChangeEvents(src,evnt)
    end
end