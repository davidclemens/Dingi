function varargout = readBigoConductivityCell(obj,path)

    nargoutchk(0,1)

    fId             = fopen(path,'r');
    if fId == -1
        warning('Dingi:DataKit:dataPool:readBigoConductivity:unableToOpenFile',...
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
    
    variables               = {'Time','Conductivity','Temperature','Salinity'};
    data                    = cat(2,seconds(time - time(1)),rawText{4:6});
    variableType            = {'Independent','Dependent','Dependent','Dependent'};
    variableOrigin          = {time(1), 0, 0 ,0};
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));

    obj.addVariable(variables,data,...
        'VariableType',             variableType,...
        'VariableOrigin',           variableOrigin,...
        'VariableMeasuringDevice',	variableMeasuringDevice);

	if nargout == 1
        varargout{1} = obj;
	end
end
