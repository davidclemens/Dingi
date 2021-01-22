function obj = importData(obj,importType,path)
    
    switch importType
        case 'BigoOptode'
            obj = readBigoOptode(obj,path);
        case 'BigoConductivityCell'
            obj = readBigoConductivityCell(obj,path);
        case 'BigoVoltage'
            obj = readBigoVoltage(obj,path);
        case 'HoboLightLogger'
            obj = readHoboLightLogger(obj,path);
        case 'SeabirdCTD'
            obj = readSeabirdCTD(obj,path);
        case 'O2Logger'
            obj = readO2Logger(obj,path);
        case 'NortekVector'
            obj = readNortekVector(obj,path);
        otherwise
            [~,validImportTypes]   = enumeration('GearKit.measuringDeviceType');
            error('Dingi:DataKit:dataPool:importData:unknownImportType',...
                    'Unknown import type ''%s''. Skipped.\nValid import types are:\n\t%s\n',importType,strjoin(validImportTypes,'\n\t'))
    end
end