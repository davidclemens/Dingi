function varargout = readBigoConductivityCell(obj,path)

    import DebuggerKit.Debugger.printDebugMessage
    
    nargoutchk(0,1)

    fId             = fopen(path,'r');
    if fId == -1
        warning('Dingi:DataKit:dataPool:readBigoConductivityCell:UnableToOpenFile',...
                'Unable to read data in:\n\t ''%s''',path)
        return
    end
    
    % Read header line and count the number of columns
    headerLine  = fgetl(fId);
    if isnumeric(headerLine) && headerLine == -1
        error('Dingi:DataKit:dataPool:readBigoConductivityCell:EmptyFile',...
            'The conductivity file ''%s'' is empty.',path)
    end
    header          = textscan(headerLine,'%s',...
                        'Delimiter',	'\t');
    header          = header{1}';
    nHeaderColumns	= numel(header);
    
    % Read first data line and count the number of columns
    dataLine    = fgetl(fId);
    frewind(fId); % Return to the beginning of the file for subsequent reading
    if isnumeric(headerLine) && headerLine == -1
        error('Dingi:DataKit:dataPool:readBigoConductivityCell:NoDataFile',...
            'The conductivity file ''%s'' has no data.',path)
    end
    data            = textscan(dataLine,'%s',...
                        'Delimiter',	'\t');
    data            = data{1}';
    nDataColumns	= numel(data);
    
    % Handle column count mismatch errors
    if nHeaderColumns < nDataColumns
        printDebugMessage('Dingi:DataKit:dataPool:readBigoConductivityCell:ColumnCountMismatch',...
            'Warning','The conductivity file ''%s'' has more data columns (%u) than header columns (%u). Only the first %u columns are processed further.',path,nDataColumns,nHeaderColumns,nHeaderColumns)
    elseif nHeaderColumns > nDataColumns
        printDebugMessage('Dingi:DataKit:dataPool:readBigoConductivityCell:ColumnCountMismatch',...
            'Warning','The conductivity file ''%s'' has more header columns (%u) than data columns (%u). Only the first %u columns are processed further.',path,nHeaderColumns,nDataColumns,nDataColumns)
    end
    
    % Build format spec and read entire file
    formatSpec = ['%{MM-dd-yyyy}D%{HH:mm:ss}D%*q%s%f%f%f',repmat('%*q',1,nDataColumns - 7)];
    rawText         = textscan(fId,formatSpec,...
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
