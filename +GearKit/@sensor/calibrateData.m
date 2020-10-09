function obj = calibrateData(obj)

    import GearKit.*
    
    for ii = 1:numel(obj)
        if obj(ii).debugger.debugLevel >= 'Info'
            fprintf('INFO: calibrating %s data... \n',obj.id);
        end

        % NOTE: remember to add new sensor ids to the 'validIds' property of the
        %       sensor class.
        switch obj(ii).id
            case 'BigoOptode'
                obj(ii) = calibrateBigoOptode(obj(ii));
            otherwise
                warning('sensor:calibrateData',...
                        'Calibration for sensor id ''%s'' not implemented yet. Skipped.\n',obj(ii).id)
        end
    
        if obj(ii).debugger.debugLevel == 'Info'
            fprintf('INFO: calibrating %s data... done\n',obj(ii).id);
        end
    end
end