function obj = readSeabirdCTDLegacy(obj,path)

    fId             = fopen(path,'r');
    if fId == -1
        warning('readSeabirdCTDLegacy:unableToOpenFile',...
                'Unable to read data in:\n\t ''%s''',path)
        return
    end                    
    rawText         = textscan(fId,'%f%f%f%{MM-dd-yyyy}D%{HH:mm:ss}D',...
                        'Delimiter',         	',',...
                        'MultipleDelimsAsOne',  false,...
                        'HeaderLines',          4);
                    
    fclose(fId);
                
    date        = datevec(rawText{4});
    time        = datevec(rawText{5});
    dt          = datetime([date(:,1:3),time(:,4:6)]);
    
    % extract serial number from filename
    measuringDevice                 = GearKit.measuringDevice();
    measuringDevice.Type            = 'SeabirdCTD';
    
	pool                    = obj.PoolCount;
    variables               = {'Time','Temperature','Pressure','Conductivity'};
    data                    = cat(2,seconds(dt - dt(1)),cat(2,rawText{1:3}));
    uncertainty             = [];
    variableType            = {'Independant','Dependant','Dependant','Dependant'};
    variableOrigin          = {dt(1), 0, 0, 0};
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));
    
    obj	= obj.addVariable(pool,variables,data,uncertainty,...
            'VariableType',             variableType,...
            'VariableOrigin',           variableOrigin,...
            'VariableMeasuringDevice',	variableMeasuringDevice);
end