classdef dataPool
    
    
    % Test: GearKit.bigoDeployment('/Users/David/Dropbox/David/university/PostDoc/data/cruises/EMB238_BIGO_data_v5/BIGO-I-01')
    
    properties
        DataRaw(1,:) cell = cell(1,0)
        Info(1,:) DataKit.Metadata.info
        Uncertainty(1,:) cell = cell(1,0)
        Flag(1,:) cell = cell(1,0)
    end
    properties (Dependent)
        PoolCount
        Index
    end
    properties (SetAccess = private)
        Data
    end
    
    methods
        function obj = dataPool()
            
        end
    end
    
    methods (Access = public)
        obj = addVariable(obj,pool,variable,data,uncertainty,varargin)
        obj = addPool(obj)
        obj = removePool(obj,pool)
        obj = importData(obj,importType,path)
        obj = setMeasuringDeviceProperty(obj,pool,idx,property,value)
        obj = setInfoProperty(obj,pool,idx,property,value)
        tbl = info(obj)
        data = getData(obj,variable,varargin)
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
        [data,info] = gd(obj,type,variable,varargin)
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