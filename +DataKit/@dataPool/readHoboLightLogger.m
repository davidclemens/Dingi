function varargout = readHoboLightLogger(obj,path)

    nargoutchk(0,1)
    
    tmpFile     = [path(1:end - 4),'.tmp'];
    copyOk      = copyfile(path,tmpFile);
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
        warning('Dingi:DataKit:dataPool:readHoboLightLogger:unableToOpenFile',...
                'Unable to read data in:\n\t ''%s''',path)
        return
    end
    rawText         = textscan(fId,'%*f%{yyyy.MM.dd HH:mm:ss}D%f%f%*s%*s%*s%*s',...
                        'Delimiter',         	'\t',...
                        'MultipleDelimsAsOne',  false,...
                        'HeaderLines',          2);
    fclose(fId);
        
    % extract serial number from filename
    measuringDevice                 = GearKit.measuringDevice();
    measuringDevice.Type            = 'HoboLightLogger';
    SN                              = regexp(path,'_(\d+)\.txt$','tokens');
    SN                              = SN{:}{:};
    measuringDevice.SerialNumber  	= SN;
    
	pool                    = obj.PoolCount;
    variables               = {'Time','Illuminance'};
    data                    = cat(2,seconds(rawText{1} - rawText{1}(1)),rawText{3});
    uncertainty             = [];
    variableType            = {'Independant','Dependant'};
    variableOrigin          = {rawText{1}(1), 0};
    variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));
    
    obj.addVariable(pool,variables,data,uncertainty,...
        'VariableType',             variableType,...
        'VariableOrigin',           variableOrigin,...
        'VariableMeasuringDevice',	variableMeasuringDevice);
        
	if nargout == 1
        varargout{1} = obj;
	end
end