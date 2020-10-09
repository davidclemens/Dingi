function obj = readBigoVoltage(obj)

    fId             = fopen(obj.dataPath,'r');
    if fId == -1
        warning('readBigoVoltage:unableToOpenFile',...
                'Unable to read %s data in:\n\t ''%s''',obj.id,obj.dataPath)
        return
    end
    rawText         = textscan(fId,'%{MM-dd-yyyy HH:mm:ss}D%f%*s',...
                        'Delimiter',         	' ',...
                        'MultipleDelimsAsOne',  true);
    fclose(fId);
    
    obj.type                    = 'voltage';
    obj.time                    = datenum(rawText{1});
    obj.data                    = rawText{2};
  	obj.timeInfo.name           = 'time';
  	obj.timeInfo.timeZone       = 'UTC';
    obj.dataInfo.id             = [14];
end