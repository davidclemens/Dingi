function readCalibrationData(obj)
% READCALIBRATIONDATA
    
    import UtilityKit.Utilities.table.readTableFile
    
    % support empty initializeation of gearDeployment subclasses
    if isempty(obj.dataFolderInfo.rootFolder)
        return
    end
    
    path            = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',char(obj.gearType),'_measuringDevicesCalibration.xlsx'];
    tmp             = readTableFile(path);
    obj.calibration = tmp(all(tmp{:,{'Cruise','Gear'}} == [obj.cruise,obj.gear],2),:);
end
