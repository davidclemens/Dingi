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
%             deriveCTDVariables(obj)
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
    
%     function deriveCTDVariables(obj)
%         for pool = 1:obj.PoolCount
%             variables = obj.Index{obj.Index{:,'DataPool'} == pool,'Variable'};
%             varIndPressure = obj.Index{variables == 'Pressure','VariableIndex'};
%             varIndSalinity = obj.Index{variables == 'Salinity','VariableIndex'};
%             
%             
%             pressure = obj.fetchVariableData(pool,varIndPressure);
%             salinity = obj.fetchVariableData(pool,varIndSalinity);
%             
%             for ii = 1:numel(salinity)
%                 SA = gsw_SA_from_SP(salinity{ii},pressure)
%             end
%         end
%         gsw_sigma0
%     end
end