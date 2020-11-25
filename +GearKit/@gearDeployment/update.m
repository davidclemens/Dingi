function obj = update(obj)
    
% 	obj = readCalibrationData(obj);
%     obj = obj.calibrateMeasuringDevices;
    obj.data = obj.data.update;
end