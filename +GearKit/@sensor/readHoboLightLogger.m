function obj = readHoboLightLogger(obj)

    tmpFile     = [obj.dataPath(1:end - 4),'.tmp'];
    copyOk      = copyfile(obj.dataPath,tmpFile);
    if copyOk == 1
        file    = memmapfile(tmpFile,...
                            'writable',     true);
        comma   = uint8(',');
        nothing = uint8('');
        mask    = file.Data == comma;
        nMask   = sum(mask);
        file.Data   = [file.Data(~mask);repmat(uint8(' '),nMask,1)];
    else
        error('')
    end



    fId             = fopen(tmpFile,'r');
    if fId == -1
        warning('readBigoVoltage:unableToOpenFile',...
                'Unable to read %s data in:\n\t ''%s''',obj.id,obj.dataPath)
        return
    end
    rawText         = textscan(fId,'%*f%{yyyy.MM.dd HH:mm:ss}D%f%f%*s%*s%*s%*s',...
                        'Delimiter',         	'\t',...
                        'MultipleDelimsAsOne',  false,...
                        'HeaderLines',          2);
    fclose(fId);
    delete(tmpFile);
        
    % extract serial number from filename
    SN              = regexp(obj.dataPath,'_(\d+)\.txt$','tokens');
    SN              = SN{:}{:};
    
    % write to sensor object
	obj.type                    = 'lightLogger';
    obj.serialNumber            = SN;
    obj.time                    = datenum(rawText{1});
    obj.data                    = rawText{3}; % cat(2,rawText{[3,2]});
  	obj.timeInfo.name           = 'time';
  	obj.timeInfo.timeZone       = 'UTC';
    obj.dataInfo.id             = [19];
end