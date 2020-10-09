function obj = readBigoOptode(obj)

    fId             = fopen(obj.dataPath,'r');
    if fId == -1
        warning('readBigoOptode:unableToOpenFile',...
                'Unable to read %s data in:\n\t ''%s''',obj.id,obj.dataPath)
        return
    end
    nOptodesRawText	= textscan(fId,'%s',1,...
                        'Delimiter',    '\n');
    frewind(fId);
    nOptodesTmp     = textscan(nOptodesRawText{1}{1},'%s',...
                        'Delimiter',         	' ',...
                        'MultipleDelimsAsOne',  true);
    nOptodes        = (numel(nOptodesTmp{1}) - 1)/4;

    formatSpec      = ['%{MM-dd-yyyy HH:mm:ss}D',repmat('%u%f%f%f',1,nOptodes)];
    rawText         = textscan(fId,formatSpec,...
                        'Delimiter',            ' ',...
                        'MultipleDelimsAsOne',  true);
    fclose(fId);
    optodeDataTmp  	= table(rawText{:});
    SN              = cellstr(num2str(optodeDataTmp{1,2:4:end}'));
    
    if nOptodes > 1
        obj = repmat(obj,nOptodes,1);
    end
    for opt = 1:nOptodes   
        obj(opt).serialNumber           = SN{opt};
        obj(opt).type                   = 'optode';
        obj(opt).time                   = datenum(rawText{1});
        obj(opt).data                   = cat(2,rawText{:,3 + 4*(opt - 1):opt*4 + 1});
        obj(opt).data(:,2)              = [];
        obj(opt).timeInfo.name          = 'time';
        obj(opt).timeInfo.timeZone      = 'UTC';
        obj(opt).dataInfo.id            = [15,16];
    end
end 














