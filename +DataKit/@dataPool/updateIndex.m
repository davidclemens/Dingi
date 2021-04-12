function varargout = updateIndex(obj)

    nargoutchk(0,1)
    
    tbl = table();
    for pool = 1:obj.PoolCount
        nVariables	= obj.Info(pool).VariableCount;
        
        dataPoolIdx             = repmat(pool,nVariables,1);
        variableIdx             = (1:nVariables)';
        independantVariableIdx  = repmat({find(obj.Info(pool).VariableType' == 'Independant')},nVariables,1);
        independantVariableIdx(obj.Info(pool).VariableType' == 'Independant') = {[]};
        variable                = obj.Info(pool).Variable';
        variableRaw             = obj.Info(pool).VariableRaw';
        variableType            = obj.Info(pool).VariableType';
        dataType                = categorical(cellfun(@class,obj.Info(pool).VariableOrigin,'un',0)');
        calibrationFcn          = obj.Info(pool).VariableCalibrationFunction';
        measuringDevice         = obj.Info(pool).VariableMeasuringDevice';
        poolInfo                = arrayfun(@(v) obj.Info(pool).selectVariable(v),(1:nVariables)');
        
        tblNew = table(...
            dataPoolIdx,...
            variableIdx,...
            independantVariableIdx,...
            variable,...
            variableRaw,...
            variableType,...
            dataType,...
            calibrationFcn,...
            measuringDevice,...
            poolInfo,...
            'VariableNames',{'DataPool','VariableIndex','IndependantVariableIndex','Variable','VariableRaw','VariableType','DataType','Calibration','MeasuringDevice','Info'});
        
        tbl = cat(1,tbl,tblNew);
    end
    
    obj.Index = tbl;

    % Mark index as updated
    obj.IndexNeedsUpdating = false;
    
    if nargout == 1
        varargout{1} = obj;
    end
end