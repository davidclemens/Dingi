function varargout = applyCalibrationFunction(obj,poolIdx,variableIdx)
% applyCalibrationFunctions  Applies calibrations
%   APPLYCALIBRATIONFUNCTIONS applies the calibration functions to the
%   DataRaw and writes the output to Data.
%
%   Syntax
%     APPLYCALIBRATIONFUNCTIONS(obj)
%     obj = APPLYCALIBRATIONFUNCTIONS(__)
%
%   Description
%     APPLYCALIBRATIONFUNCTIONS(obj) applies calibrations.
%     obj = APPLYCALIBRATIONFUNCTIONS(__) additionally returns the dataPool
%       handle.
%
%   Example(s)
%     APPLYCALIBRATIONFUNCTIONS(obj)
%
%
%   Input Arguments
%     obj - data pool instance
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%
%   Output Arguments
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
%   Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)
%
    nargoutchk(0,1)
    
    if ~isscalar(poolIdx) || ~isscalar(variableIdx)
        error('Dingi:DataKit:dataPool:applyCalibrationFunction',...
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
    
    if nargout == 1
        varargout{1} = obj;
    end
end