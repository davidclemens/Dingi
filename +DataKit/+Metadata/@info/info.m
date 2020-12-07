classdef info
    
    
    properties
        Variable(1,:) DataKit.Metadata.variable
        VariableRaw(1,:) DataKit.Metadata.variable
        VariableType(1,:) DataKit.Metadata.validators.validInfoVariableType
        VariableDescription(1,:) cell
        VariableFactor(1,:) double
        VariableOffset(1,:) double
        VariableOrigin(1,:) cell
        VariableCalibrationFunction(1,:) cell
        VariableMeasuringDevice(1,:) GearKit.measuringDevice
    end
    properties (Dependent)
        VariableId(1,:) {mustBeInteger, mustBeNonnegative, mustBeLessThan(VariableId, 65535)}
        VariableUnit(1,:) categorical
        VariableRawUnit(1,:) categorical
        VariableCount(1,1) double
        VariableIsCalibrated(1,:) logical
    end
    properties (Dependent, Hidden)
        NoIndependantVariable
        VariableReturnDataType
    end
    
    methods
        function obj = info(variable,varargin)
            
            if nargin == 0
                variable        = '';
            end
          	variableCount   = numel(variable);
            
            % parse Name-Value pairs
            optionName          = {'VariableType','VariableFactor','VariableOffset','VariableCalibrationFunction','VariableOrigin','variableDescription','variableMeasuringDevice'}; % valid options (Name)
            optionDefaultValue  = {repmat({'Dependant'},1,variableCount),ones(1,variableCount),zeros(1,variableCount),repmat({@(x) x},1,variableCount),zeros(1,variableCount),repmat({''},1,variableCount),repmat(GearKit.measuringDevice(),1,variableCount)}; % default value (Value)
            [variableType,...
             variableFactor,...
             variableOffset,...
             variableCalibrationFunction,...
             variableOrigin,...
             variableDescription,...
             variableMeasuringDevice...
                ]               = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

         	obj	= obj.addVariable(variable,...
                    'VariableType',                 variableType,...
                    'VariableFactor',               variableFactor,...
                    'VariableOffset',               variableOffset,...
                    'VariableCalibrationFunction',	variableCalibrationFunction,...
                    'VariableOrigin',               variableOrigin,...
                    'VariableDescription',          variableDescription,...
                    'VariableMeasuringDevice',      variableMeasuringDevice);
        end
    end
    methods
        obj = addVariable(obj,variable,varargin)
        obj = removeVariable(obj,ind)
        tbl = info2table(obj)
        obj = selectVariable(obj,variableIdx)
    end
    methods (Access = private)
        obj = validateProperties(obj)
        obj = validateInfoObj(obj)
        obj = updateVariableRaw(obj)
    end
    
    % set methods
    methods
        function obj = set.Variable(obj,value)
            
            obj = updateVariableRaw(obj);
            obj.Variable = value;
        end
    end
    % get methods
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
            VariableIsCalibrated = ~cellfun(@(f) strcmp(func2str(f),'@(t,x)x'),obj.VariableCalibrationFunction);
        end
        function NoIndependantVariable = get.NoIndependantVariable(obj)
            NoIndependantVariable = ~any(obj.VariableType == 'Independant');
        end
        function VariableReturnDataType = get.VariableReturnDataType(obj)
            VariableReturnDataType = categorical(cellfun(@class,obj.VariableOrigin,'un',0));
        end
%         function VariableRaw = get.VariableRaw(obj)
%             obj = updateVariableRaw(obj);
%             VariableRaw = obj.VariableRaw;
%         end
    end
end