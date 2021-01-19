function readCalibrationData(obj)
% READCALIBRATIONDATA
    
    import DataKit.importTableFile
    
    path            = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',obj.gearType,'_measuringDevicesCalibration.xlsx'];
    tmp             = importTableFile(path);
    obj.calibration = tmp(all(tmp{:,{'Cruise','Gear'}} == [obj.cruise,obj.gear],2),:);
end