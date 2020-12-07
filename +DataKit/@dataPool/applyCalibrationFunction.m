function obj = applyCalibrationFunction(obj,poolIdx,variableIdx)
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
        
        if ~isscalar(poolIdx) || ~isscalar(variableIdx)
            error('DataKit:dataPool:applyCalibrationFunction',...
                'Only works in a scalar context.')
        end
        fh       = obj.Info(poolIdx).VariableCalibrationFunction{variableIdx};
        
        if strcmp(func2str(fh),'@(t,x)x')
            % return if the identity calibration function is set
            return
        end
        
        
        if obj.Info(poolIdx).VariableCount == 0
        % skip this data pool if there is no variable
            return
        end
        maskTimeIdx	= obj.Index{:,'DataPool'} == poolIdx & ...
                      obj.Index{:,'VariableType'} == 'Independant' & ...
                      obj.Index{:,'Variable'} == 'Time';
        timeIdx     = obj.Index{maskTimeIdx,'VariableIndex'};
        
        
        if isempty(timeIdx)
            % skip this data pool if there is not independant time variable
            time    = NaN(size(obj.DataRaw{poolIdx},1),1);
        else
            time	= datenum(obj.fetchVariableData(poolIdx,timeIdx,...
                        'ReturnRawData',    true,...
                        'ForceCellOutput',  false));
        end

        obj.Data{poolIdx}(:,variableIdx)	= fh(time,obj.DataRaw{poolIdx}(:,variableIdx));
end