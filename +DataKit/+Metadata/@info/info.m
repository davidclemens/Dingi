classdef info
    
    
    properties
        VariableDescription(1,:) cell
        VariableFactor(1,:) double
        VariableOffset(1,:) double
        VariableMeasuringDevice(1,:) GearKit.measuringDevice
    end
    properties (SetAccess = private)
% TODO: use the validParameter enumeration class
%         VariableId(1,:) DataKit.Metadata.validators.validParameter
        VariableId(1,:) {mustBeAValidParameterId, mustBeInteger, mustBeNonnegative, mustBeLessThan(VariableId, 65535)}
        VariableType(1,:) DataKit.Metadata.validators.validInfoVariableType
    end
    properties (Dependent)
        VariableName(1,:) categorical
        VariableUnit(1,:) categorical
        VariableCount(1,1) double
    end
    
    methods
        function obj = info(id,varargin)
            

            variableCount   = numel(id);
            
            % parse Name-Value pairs
            optionName          = {'VariableType','VariableFactor','VariableOffset','variableDescription','variableMeasuringDevice'}; % valid options (Name)
            optionDefaultValue  = {repmat({'Dependant'},1,variableCount),ones(1,variableCount),zeros(1,variableCount),repmat({''},1,variableCount),repmat(GearKit.measuringDevice(),1,variableCount)}; % default value (Value)
            [variableType,...
             variableFactor,...
             variableOffset,...
             variableDescription,...
             variableMeasuringDevice...
                ]               = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

         	obj	= obj.addVariable(id,...
                    'VariableType',             variableType,...
                    'VariableFactor',           variableFactor,...
                    'VariableOffset',           variableOffset,...
                    'VariableDescription',      variableDescription,...
                    'VariableMeasuringDevice',	variableMeasuringDevice);
        end
    end
    methods
        obj = addVariable(obj,id,varargin)
        obj = removeVariable(obj,ind)
    end
    methods (Access = private)
        obj = validateProperties(obj)
    end
    
    % get methods
    methods
        function VariableName = get.VariableName(obj)
            [~,info]        = DataKit.validateParameterId(obj.VariableId);
            VariableName    = info{:,'Abbreviation'}';
        end
        function VariableUnit = get.VariableUnit(obj)
            [~,info]        = DataKit.validateParameterId(obj.VariableId);
            VariableUnit    = info{:,'Unit'}';
        end
        function VariableCount = get.VariableCount(obj)
            VariableCount = numel(obj.VariableId);
        end
    end
end

function mustBeAValidParameterId(id)
% Throws an error if any id in id is not a valid parameterId
    isValid  = DataKit.validateParameterId(id);
    if ~all(isValid)
        eidType = 'DataKit:Metadata:info:ivalidParameterId';
        msgType = 'Value assigned to the VariabeleId property is not a valid ParameterId.';
        throwAsCaller(MException(eidType,msgType))
    end
end