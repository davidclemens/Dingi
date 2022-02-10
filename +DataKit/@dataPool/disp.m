function disp(obj)
% disp  Displays metadata of a datapool instance
%   DISP displays metadata of a datapool instance. It overloads the builtin
%   disp(x) function.
%
%   Syntax
%     data = DISP(dp)
%
%   Description
%     data = DISP(dp) displays metadata of a datapool instance.
%
%   Example(s)
%     data = DISP(dp)
%
%
%   Input Arguments
%     dp - data pool
%       DataKit.dataPool
%         An instance of the DataKit.dataPool class.
%
%
%   Output Arguments
%
%
%   Name-Value Pair Arguments
%
%
%   See also DATAPOOL
%
%   Copyright (c) 2020-2022 David Clemens (dclemens@geomar.de)
%
    if obj.PoolCount == 0
        fprintf('\tempty dataPool instance\n')
        return
    end
    
    info = obj.info;
    
    info.MeasuringDeviceType                = categorical(cellstr([info.MeasuringDevice.Type])');
    info.MeasuringDeviceSerialNumber     	= categorical({info.MeasuringDevice.SerialNumber}');
    info.MeasuringDeviceMountingLocation 	= categorical({info.MeasuringDevice.MountingLocation}');
    info.MeasuringDeviceWorldDomain     	= categorical(cellstr([info.MeasuringDevice.WorldDomain])');
    
    info.Variable           = categorical(cellstr(info{:,'Variable'}));   
    info.MeasuringDevice    = [];
    
    disp(info)
end