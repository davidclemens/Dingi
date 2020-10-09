function obj = readSeabirdCTDLegacy(obj)

    fId             = fopen(obj.dataPath,'r');
    if fId == -1
        warning('readSeabirdCTDLegacy:unableToOpenFile',...
                'Unable to read %s data in:\n\t ''%s''',obj.id,obj.dataPath)
        return
    end                    
    rawText         = textscan(fId,'%f%f%f%{MM-dd-yyyy}D%{HH:mm:ss}D',...
                        'Delimiter',         	',',...
                        'MultipleDelimsAsOne',  false,...
                        'HeaderLines',          4);
                    
    fclose(fId);
                
    date        = datevec(rawText{4});
    time        = datevec(rawText{5});
    
    obj.type                    = 'ctd';
    obj.time                    = datenum([date(:,1:3),time(:,4:6)]);
    obj.data                    = cat(2,rawText{1:3});
  	obj.timeInfo.name           = 'time';
  	obj.timeInfo.timeZone       = 'UTC';
    obj.dataInfo.id             = [16,23,17];
end