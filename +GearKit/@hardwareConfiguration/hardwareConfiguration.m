classdef hardwareConfiguration < handle
    properties (Dependent)
        DeviceDomains
    end
    properties %(Hidden)
        GearDeployment
        DeviceDomainMetadata table = table.empty
    end
    methods
        function obj = hardwareConfiguration(gearDeployment)
            
            if ~isa(gearDeployment,'GearKit.gearDeployment')
                error('Dingi:GearKit:hardwareConfiguration:hardwareConfiguration:invalidInputType',...
                    'Invalid input type.')
            end
            obj.GearDeployment = gearDeployment;
        end
    end
    
    % Get methods
    methods
        function DeviceDomains = get.DeviceDomains(obj)
            DeviceDomains       = table();
            MeasuringDevices	= unique(cat(2,obj.GearDeployment.data.Info.VariableMeasuringDevice)');
            
            DeviceDomains.DeviceDomain      = cat(1,MeasuringDevices.DeviceDomain);
            DeviceDomains.WorldDomain       = cat(1,MeasuringDevices.WorldDomain);
            DeviceDomains.MeasuringDevice   = MeasuringDevices;
            DeviceDomains   = sortrows(DeviceDomains,{'DeviceDomain'})
            
        end
    end
end