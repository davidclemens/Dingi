function obj = readBigoConductivityCell(obj,path)
    
    fId             = fopen(path,'r');
    if fId == -1
        warning('DataKit:dataPool:readBigoConductivity:unableToOpenFile',...
                'Unable to read data in:\n\t ''%s''',path)
        return
    end

    rawText         = textscan(fId,'%{MM-dd-yyyy}D%{HH:mm:ss}D%*q%s%f%f%f%*f%*f',...
                        'Delimiter',         	'\t',...
                        'MultipleDelimsAsOne',  false,...
                        'HeaderLines',          1);
    fclose(fId);

    measuringDevice                 = GearKit.measuringDevice();
    measuringDevice.Type            = 'BigoConductivityCell';
    measuringDevice.SerialNumber  	= rawText{3}{1};

    tmpDate          	= datevec(rawText{1});
    tmpTime           	= datevec(rawText{2});
    time                = datetime([tmpDate(:,1:3),tmpTime(:,4:6)]);
    
	pool                    = obj.PoolCount;
    variables               = {'Time','Conductivity','Temperature','Salinity'};
    data                    = cat(2,seconds(time - time(1)),rawText{4:6});
    uncertainty             = [];
    variableType            = {'Independant','Dependant','Dependant','Dependant'};
    variableOrigin          = {time(1), 0, 0 ,0};
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));
    
    obj	= obj.addVariable(pool,variables,data,uncertainty,...
            'VariableType',             variableType,...
            'VariableOrigin',           variableOrigin,...
            'VariableMeasuringDevice',	variableMeasuringDevice);
end