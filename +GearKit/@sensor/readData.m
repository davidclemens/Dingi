function obj = readData(obj)

    import GearKit.*
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: reading %s data... \n',obj.id);
	end
    
    % NOTE: remember to add new sensor ids to the 'validIds' property of the
    %       sensor class.
    switch obj.id
        case 'BigoOptode'
            obj = readBigoOptode(obj);
        case 'BigoConductivity'
            obj = readBigoConductivity(obj);
        case 'BigoVoltage'
            obj = readBigoVoltage(obj);
        case 'HoboLightLogger'
            obj = readHoboLightLogger(obj);
        case 'SeabirdCTD'
            obj = readSeabirdCTD(obj);
        case 'O2Logger'
            obj = readO2Logger(obj);
        case 'NortekVector'
            obj = readNortekVector(obj);
        otherwise
            error('sensor:readData',...
                    'Unknown sensor id ''%s''. Skipped.\nValid sensor ids are:\n\t%s',obj.id,strjoin(obj.validIds,', '))
    end
    
    [obj.dataRaw]       = obj.data;
    for oo = 1:numel(obj)
        obj(oo).isOutlier     = false(size(obj(oo).data));
    end
    for sens = 1:numel(obj)
        obj(sens).dataInfo.idRaw                = obj(sens).dataInfo.id;  
        obj(sens).dataInfo.calibrationFunction  = repmat({@(x) x},1,obj(sens).dataInfo.nParameters);
    end
    
    for ii = 1:numel(obj)
        if obj(ii).debugger.debugLevel == 'Info'
            fprintf('INFO: reading %s data... done\n',obj(ii).id);
        elseif obj(ii).debugger.debugLevel == 'Verbose'
            fprintf('VERBOSE: reading %s data... done\n\tsample(s): %g\n\tinterval:  %g s\n',obj(ii).id,obj(ii).dataInfo.nSamples,round(obj(ii).timeInfo.sampleInterval,3,'significant'));
        end
    end
end