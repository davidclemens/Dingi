classdef dataPool
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
    %   addPool - add a data pool to a dataPol instance
    %   addVariable - add a variable to a data pool
    %   fetchData - gathers data from a datapool object in various ways
    %   disp - displays metadata of a datapool instance
    %
    % Copyright 2020 David Clemens (dclemens@geomar.de)
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
        Data % Data with calibration functions applied
    end
    
    methods
        function obj = dataPool()
            
        end
    end
    
    methods (Access = public)
        obj = addPool(obj)
        obj = addVariable(obj,pool,variable,data,uncertainty,varargin)
        obj = removePool(obj,pool)
        obj = importData(obj,importType,path)
        obj = setMeasuringDeviceProperty(obj,pool,idx,property,value)
        obj = setInfoProperty(obj,pool,idx,property,value)
        tbl = info(obj)
        data = fetchData(obj,varargin)
        data = fetchVariableData(obj,poolIdx,variableIdx,varargin)
        obj = update(obj)
        varargout = plotCalibrations(obj)
    end
    
    methods (Access = private)
        obj = readBigoVoltage(obj,path)
        obj = readBigoOptode(obj,path)
        obj = readBigoConductivityCell(obj,path)
        obj = readHoboLightLogger(obj,path)
        obj = readSeabirdCTD(obj,path)
        obj = readNortekVector(obj,path)
        obj = readO2Logger(obj,path)
        obj = readSeabirdCTDLegacy(obj,path)
        obj = applyCalibrationFunctions(obj)
    end
    
  	% overloaded methods
    methods (Access = public)
        disp(obj)        
    end
    
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
    end
end