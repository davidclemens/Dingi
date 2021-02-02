classdef measuringDevice
    
    properties
        Type(1,1) GearKit.measuringDeviceType = GearKit.measuringDeviceType.undefined
        SerialNumber(1,:) char = ''
        MountingLocation(1,:) char = ''
        WorldDomain(1,1) GearKit.worldDomain = GearKit.worldDomain.undefined
        DeviceDomain(1,1) GearKit.deviceDomain = GearKit.deviceDomain.undefined
    end
    
    methods
        function obj = measuringDevice(varargin)
            narginchk(0,5)
            
            isChar      = cellfun(@ischar,varargin);
            if any(~isChar)
                error('Dingi:GearKit:measuringDevice:measuringDevice:invalidInputType',...
                    'Invalid input type. Only char allowed.')
            end
            
            if nargin == 0
                return
            end
            if nargin >= 1
                obj.Type = GearKit.measuringDeviceType.(varargin{1});
            end
            if nargin >= 2
                obj.SerialNumber = varargin{2};
            end
            if nargin >= 3
                obj.MountingLocation = varargin{3};
            end
            if nargin >= 4
                obj.WorldDomain = GearKit.worldDomain.(varargin{4});
            end
            if nargin >= 5
                obj.DeviceDomain = GearKit.deviceDomain.(varargin{5});
            end
        end
    end
    
    % overloaded methods
    methods
        bool = eq(a,b)
        [C,ia,ic] = unique(A,varargin)
        disp(obj)
    end
    methods (Static)
        list = listAllMeasuringDevice()
    end
end