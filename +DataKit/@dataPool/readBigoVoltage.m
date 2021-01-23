function obj = readBigoVoltage(obj,path)

    fId             = fopen(path,'r');
    if fId == -1
        warning('Dingi:DataKit:dataPool:readBigoVoltage:unableToOpenFile',...
                'Unable to read data in:\n\t ''%s''',path)
        return
    end
    
    rawText         = textscan(fId,'%{MM-dd-yyyy HH:mm:ss}D%f%*s',...
                        'Delimiter',         	' ',...
                        'MultipleDelimsAsOne',  true);
    fclose(fId);
    
    measuringDevice         = GearKit.measuringDevice();
    measuringDevice.Type    = 'BigoVoltage';
    SN                      = regexp(path,'/CHMB(?<ControlUnit>\d+)/SPL_VLTG.TXT$','names');
    measuringDevice.SerialNumber = ['BVCU',num2str(str2double(SN.ControlUnit),'%02.0f')];
    
    pool                    = obj.PoolCount;
    variables               = {'Time','Voltage'};
    data                    = cat(2,seconds(rawText{1} - rawText{1}(1)),rawText{2});
    uncertainty             = [];
    variableType            = {'Independant', 'Dependant'};
    variableOrigin          = {rawText{1}(1), 0};
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));
    
    obj	= obj.addVariable(pool,variables,data,uncertainty,...
            'VariableType',             variableType,...
            'VariableOrigin',           variableOrigin,...
            'VariableMeasuringDevice',	variableMeasuringDevice);
end