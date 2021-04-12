function varargout = importData(obj,importType,path)
    
    nargoutchk(0,1)
    
    switch importType
        case 'BigoOptode'
            readBigoOptode(obj,path);
        case 'BigoConductivityCell'
            readBigoConductivityCell(obj,path);
        case 'BigoVoltage'
            readBigoVoltage(obj,path);
        case 'HoboLightLogger'
            readHoboLightLogger(obj,path);
        case 'SeabirdCTD'
            readSeabirdCTD(obj,path);
        case 'O2Logger'
            readO2Logger(obj,path);
        case 'NortekVector'
            readNortekVector(obj,path);
        otherwise
            [~,validImportTypes]   = enumeration('GearKit.measuringDeviceType');
            error('Dingi:DataKit:dataPool:importData:unknownImportType',...
                    'Unknown import type ''%s''. Skipped.\nValid import types are:\n\t%s\n',importType,strjoin(validImportTypes,'\n\t'))
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end