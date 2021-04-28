function varargout = readBigoOptode(obj,path)

    nargoutchk(0,1)

    fId             = fopen(path,'r');
    if fId == -1
        warning('Dingi:DataKit:dataPool:readBigoOptode:unableToOpenFile',...
                'Unable to read data in:\n\t ''%s''',path)
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
    
    newPoolInd      = obj.PoolCount + 1;
    for opt = 1:nOptodes
        measuringDevice                 = GearKit.measuringDevice();
        measuringDevice.Type            = 'BigoOptode';
        measuringDevice.SerialNumber    = SN{opt};

        data    	= cat(2,rawText{:,3 + 4*(opt - 1):opt*4 + 1});
        data(:,2) 	= [];

        if opt == 1
            variables               = {'Time','Oxygen','Temperature'};
            data                    = cat(2,seconds(rawText{1} - rawText{1}(1)),data);
            variableType            = {'Independent','Dependent','Dependent'};
            variableOrigin          = {rawText{1}(1),0,0};
            variableMeasuringDevice = repmat(measuringDevice,1,size(data,2));
        else
            variables               = {'Oxygen','Temperature'};
            variableType            = {'Dependent','Dependent'};
            variableOrigin          = {0,0};
            variableMeasuringDevice = repmat(measuringDevice,1,size(data,2));
        end

        obj.addVariable(variables,data,...
            'Pool',                     newPoolInd,...
            'VariableType',             variableType,...
            'VariableOrigin',           variableOrigin,...
            'VariableMeasuringDevice',	variableMeasuringDevice);
    end

	if nargout == 1
        varargout{1} = obj;
	end
end
