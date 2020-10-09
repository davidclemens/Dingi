function obj = readBigoConductivity(obj)
    
    fId             = fopen(obj.dataPath,'r');
    if fId == -1
        warning('readBigoConductivity:unableToOpenFile',...
                'Unable to read %s data in:\n\t ''%s''',obj.id,obj.dataPath)
        return
    end

    rawText         = textscan(fId,'%{MM-dd-yyyy}D%{HH:mm:ss}D%*q%s%f%f%f%*f%*f',...
                        'Delimiter',         	'\t',...
                        'MultipleDelimsAsOne',  false,...
                        'HeaderLines',          1);
    fclose(fId);

    obj.serialNumber  	= rawText{3}{1};
    obj.type          	= 'conductivity';

    tmpDate          	= datevec(rawText{1});
    tmpTime           	= datevec(rawText{2});
    
    obj.time                    = datenum([tmpDate(:,1:3),tmpTime(:,4:6)]);
    obj.data                    = cat(2,rawText{4:6});
  	obj.timeInfo.name           = 'time';
    obj.timeInfo.timeZone       = 'UTC';
    obj.dataInfo.id             = [17,16,18];
end