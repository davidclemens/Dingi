classdef dataMetadata
    properties
        id uint16
        idRaw uint16
        isCalibrated logical = logical.empty
        calibrationFunction cell = {}
        nParameters = 0
        nSamples = NaN
    end
    properties (SetAccess = private)
        name cell = {}
        nameRaw cell = {}
        unit categorical
        unitRaw categorical
        description cell = {}
        descriptionRaw cell = {}
    end
    properties (Hidden) 
    end
    
    methods
%         function obj = setDefault(obj)
%             obj.name                = strcat({'data'},cellstr(num2str((1:obj.nParameters)','%g')))';
%             obj.nameLabel           = repmat({''},1,obj.nParameters);
%             obj.nameRaw             = repmat({''},1,obj.nParameters);
%             obj.nameRawLabel        = repmat({''},1,obj.nParameters);
%             obj.unit                = repmat({''},1,obj.nParameters);
%             obj.unitLabel           = repmat({''},1,obj.nParameters);
%             obj.unitRaw             = repmat({''},1,obj.nParameters);
%             obj.unitRawLabel        = repmat({''},1,obj.nParameters);
%             obj.description         = repmat({''},1,obj.nParameters);
%             obj.isCalibrated        = false(1,obj.nParameters);
%             
%             obj.calibrationFunction	= repmat({@(x) x},1,obj.nParameters);
%         end
        
        % set methods
        
        
        function obj = set.id(obj,value)
            
            [parameterIdIsValid,parameterInfo] = DataKit.validateParameterId(value);
            if all(parameterIdIsValid)
                obj.id          = parameterInfo{parameterIdIsValid,'ParameterId'}';
                obj.name        = parameterInfo{parameterIdIsValid,'Parameter'}';
                obj.unit        = parameterInfo{parameterIdIsValid,'Unit'}';
                obj.description	= parameterInfo{parameterIdIsValid,'Description'}';
            else
                invalidParameterIndex = find(~parameterIdIsValid,1);
                error('GearKit:dataMetadata:invalidParameter',...
                      '''%g'' is an invalid parameter id.',value(invalidParameterIndex))
            end
            
        end
        function obj = set.idRaw(obj,value)
            
            [parameterIdIsValid,parameterInfo] = DataKit.validateParameterId(value);
            if all(parameterIdIsValid)
                obj.idRaw           = parameterInfo{parameterIdIsValid,'ParameterId'}';
                obj.nameRaw         = parameterInfo{parameterIdIsValid,'Parameter'}';
                obj.unitRaw         = parameterInfo{parameterIdIsValid,'Unit'}';
                obj.descriptionRaw	= parameterInfo{parameterIdIsValid,'Description'}';
            else
                invalidParameterIndex = find(~parameterIdIsValid,1);
                error('GearKit:dataMetadata:invalidParameter',...
                      '''%g'' is an invalid parameter id.',value(invalidParameterIndex))
            end
        end
        function obj = set.calibrationFunction(obj,value)
            
            if ~isempty(obj.calibrationFunction)
                obj.isCalibrated = ~cellfun(@(fh) strcmp(func2str(fh),'@(x)x'),value);
            end
            obj.calibrationFunction = value;
        end
    end
end