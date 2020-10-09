function obj = readO2Logger(obj)
    
    fId             = fopen(obj.dataPath,'r');
    if fId == -1
        warning('readO2Logger:unableToOpenFile',...
                'Unable to read %s data in:\n\t ''%s''',obj.id,obj.dataPath)
        return
    end
    
    rawHeader     	= textscan(fId,'%s',4,...
                        'Delimiter',         	',',...
                        'MultipleDelimsAsOne',  false,...
                        'HeaderLines',          0);
	frewind(fId);
    rawText         = textscan(fId,'%{ddMMyy}D%{HHmmss}D%f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f',...
                        'Delimiter',         	',',...
                        'MultipleDelimsAsOne',  false,...
                        'HeaderLines',          4);
    fclose(fId);
    
    SN          = regexp(rawHeader{1}{2},'SerNum\s:\s(\d+)$','tokens');
    date        = datevec(rawText{1});
    time        = datevec(rawText{2});
    
    
    obj.type                    = 'optode';
    obj.serialNumber            = SN{1}{1};
    obj.time                    = datenum([date(:,1:3),time(:,4:6)]);
    obj.data                    = cat(2,rawText{3:4});
  	obj.timeInfo.name           = 'time';
  	obj.timeInfo.timeZone       = 'UTC';
    obj.dataInfo.id             = [15,16];
end