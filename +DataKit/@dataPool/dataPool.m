classdef dataPool < handle
    % dataPool  Store & manage self-descriptive measurement data
    % A data pool instance can contain a variety of data from multiple
    % sources. The data is self describing, which means that metadata such
    % as units are consistant.
    %
    % dataPool Properties:
    %   DataRaw - Data without calibration functions applied
    %   Data - Data with calibration functions applied
    %   Info - Data pool metadata
    %   Uncertainty - Uncertainty of DataRaw
    %   Flag - Flags of DataRaw
    %   Index - An overview table of all variables in the data pool
    %   PoolCount - The number of data pools
    %
    % dataPool Methods:
    %   addPool - Add a data pool to a dataPol instance
    %   addVariable - Add a variable to a data pool
    %   fetchData - Gathers data from a datapool object in various ways
    %   disp - Displays metadata of a datapool instance
    %
    % Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
    %
    
    properties
        DataRaw(1,:) cell = cell(1,0) % Data without calibration functions applied
        Info(1,:) DataKit.Metadata.info % Data pool metadata
        Uncertainty(1,:) cell = cell(1,0) % Uncertainty of DataRaw
        Flag(1,:) cell = cell(1,0) % Flags of DataRaw
    end
    properties (Dependent)
        PoolCount % The number of data pools
        Index % An overview table of all variables in the data pool
    end
    properties (SetAccess = private)
        Data(1,:) cell = cell(1,0) % Data with calibration functions applied
    end
    properties (Dependent, Hidden)
        PropertyList
    end
    
    methods
        function obj = dataPool()
            
        end
    end
    
    methods (Access = public)
        varargout = addPool(obj)
        varargout = addVariable(obj,pool,variable,data,uncertainty,varargin)
        varargout = removePool(obj,pool)
        varargout = importData(obj,importType,path)
        varargout = setMeasuringDeviceProperty(obj,pool,idx,property,value)
        varargout = setInfoProperty(obj,pool,idx,property,value)
        tbl = info(obj)
        data = fetchData(obj,varargin)
        [data,flags] = fetchVariableData(obj,poolIdx,variableIdx,varargin)
        varargout = applyCalibrationFunction(obj,poolIdx,variableIdx)
        [poolIdx,variableIdx] = findVariable(obj,varargin)
        varargout = setFlag(obj,poolIdx,i,j,flag,highlow)
        tf = isequal(objA,objB)
    end
    
    methods (Access = private)
        varargout = readBigoVoltage(obj,path)
        varargout = readBigoOptode(obj,path)
        varargout = readBigoConductivityCell(obj,path)
        varargout = readHoboLightLogger(obj,path)
        varargout = readSeabirdCTD(obj,path)
        varargout = readNortekVector(obj,path)
        varargout = readO2Logger(obj,path)
        varargout = readSeabirdCTDLegacy(obj,path)
    end
    
  	% Overloaded methods
    methods (Access = public)
        disp(obj)        
    end
    
    % Get methods
    methods
        function PoolCount = get.PoolCount(obj)
            PoolCount = numel(obj.DataRaw);
        end
        function Index = get.Index(obj)
            Index = table();
            for pool = 1:obj.PoolCount
                nVariables	= obj.Info(pool).VariableCount;
                independantVariableIdx  = repmat({find(obj.Info(pool).VariableType' == 'Independant')},nVariables,1);
                independantVariableIdx(obj.Info(pool).VariableType' == 'Independant') = {[]};
                
                Index       = cat(1,Index,table(...
                                            repmat(pool,nVariables,1),...
                                            (1:nVariables)',...
                                            independantVariableIdx,...
                                            obj.Info(pool).Variable',...
                                            obj.Info(pool).VariableRaw',...
                                            obj.Info(pool).VariableType',...
                                            categorical(cellfun(@class,obj.Info(pool).VariableOrigin,'un',0)'),...
                                            obj.Info(pool).VariableCalibrationFunction',...
                                            obj.Info(pool).VariableMeasuringDevice',...
                                            arrayfun(@(v) obj.Info(pool).selectVariable(v),(1:nVariables)'),...
                                            'VariableNames',{'DataPool','VariableIndex','IndependantVariableIndex','Variable','VariableRaw','VariableType','DataType','Calibration','MeasuringDevice','Info'}));

            end
        end
        function PropertyList = get.PropertyList(obj)
            for pool = 1:obj.PoolCount
                nVariables	= obj.Info(pool).VariableCount;
                propertyNames = properties(obj.Info(pool));
                
                % only look at properties that hold as many elements as
                % there are variables
               	indProperties = find(cellfun(@(prop) numel(obj.Info(pool).(prop)),propertyNames) == nVariables);
                nProperties = numel(indProperties);
                
                independantVariableIdx  = repmat({find(obj.Info(pool).VariableType' == 'Independant')},nVariables,1);
                independantVariableIdx(obj.Info(pool).VariableType' == 'Independant') = {[]};
                
             	value = cell(nProperties,nVariables);
                for prop = 1:nProperties
                    value(prop,:) = mat2cell(obj.Info(pool).(propertyNames{indProperties(prop)})(:),ones(1,nVariables),1);
                end
                propertyListNew = cell2struct(value,propertyNames(indProperties));
                
                for vv = 1:nVariables
                    propertyListNew(vv).poolIdx         = pool;
                    propertyListNew(vv).variableIdx     = vv;
                end
                
                % append to list
                if pool == 1
                    PropertyList       = propertyListNew;
                else
                    PropertyList       = cat(1,PropertyList,propertyListNew);
                end
            end
        end
    end
end