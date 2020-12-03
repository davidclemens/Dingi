function obj = applyCalibrationFunctions(obj)
% applyCalibrationFunctions  Applies calibrations
%   APPLYCALIBRATIONFUNCTIONS applies the calibration functions to the
%   DataRaw and writes the output to Data.
%
%   Syntax
%     obj = APPLYCALIBRATIONFUNCTIONS(obj)
%
%   Description
%     obj = APPLYCALIBRATIONFUNCTIONS(obj) applies calibrations
%
%   Example(s)
%     obj = APPLYCALIBRATIONFUNCTIONS(obj)
%
%
%   Input Arguments
%     obj - data pool instance
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%
%   Output Arguments
%
%     obj - returned data pool instance
%       DataKit.dataPool
%         The new instance of the DataKit.dataPool class.
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAPOOL
%
%   Copyright 2020 David Clemens (dclemens@geomar.de)
%

    Data    = cell(size(obj.DataRaw));
    for dp = 1:obj.PoolCount
        if obj.Info(dp).VariableCount == 0
        % skip this data pool if there is no variable
            continue
        end
        maskTimeIdx	= obj.Index{:,'DataPool'} == dp & ...
                      obj.Index{:,'VariableType'} == 'Independant' & ...
                      obj.Index{:,'Variable'} == 'Time';
        timeIdx     = obj.Index{maskTimeIdx,'VariableIndex'};
        
        if isempty(timeIdx)
            % skip this data pool if there is not independant time variable
            continue
        end
        
        time        = datenum(obj.fetchVariableData(dp,timeIdx,...
                      	'ReturnRawData',    true,...
                        'ForceCellOutput',  false));
        
        maskDataIdx	= obj.Index{:,'DataPool'} == dp;
        dataIdx     = obj.Index{maskDataIdx,'VariableIndex'};
        
        funcs       = obj.Info(dp).VariableCalibrationFunction(dataIdx);

        newData     = cellfun(@(v,f) f(time,obj.DataRaw{dp}(:,v)),num2cell(dataIdx)',funcs,'un',0);
        Data{dp}    = cat(2,newData{:});
    end
    obj.Data    = Data;
end