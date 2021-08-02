function setFitVariables(obj)

    info                = obj.Bigo.data.info;
    info.DeviceDomain   = cat(1,info{:,'MeasuringDevice'}.DeviceDomain);
    info.WorldDomain    = cat(1,info{:,'MeasuringDevice'}.WorldDomain);
    info                = outerjoin(info,obj.Bigo.HardwareConfiguration.DeviceDomainMetadata,...
                            'LeftKeys',         'DeviceDomain',...
                            'RightKeys',        'DeviceDomain',...
                            'MergeKeys',        true,...
                            'Type',             'left');

    % Variables that should be fitted are dependant variables in the 
    % bigoDeployment data pools that match any of the deviceDomain of 
    % property 'FitDeviceDomains'
    % Also only concentration data can be fitted right now.
    mask    = false(size(info,1),obj.NDeviceDomains);
    for dd = 1:obj.NDeviceDomains
        mask(:,dd) = info{:,'DeviceDomain'} == obj.DeviceDomains(dd) & ...
                   	 info{:,'WorldDomain'} == 'BenthicWaterColumn';
    end
    mask    = any(mask & ...
                  info{:,'Type'} == 'Dependent' & ...
                  ismember({info{:,'Variable'}.Unit}','µM'), ...
              	2);
	
	if sum(mask) == 0
        warning('Dingi:AnalysisKit:bigoFluxAnalysis:setFitVariables:noVariableFound',...
            'There was no variable for fitting found.')
	end
    
    info    = info(mask,:);
    
    % Set properties
    obj.NFits               = size(info,1);
    obj.PoolIndex           = info{:,'DataPoolIndex'};
    obj.VariableIndex       = info{:,'VariableIndex'};
    obj.FitDeviceDomains    = info{:,'DeviceDomain'};
    obj.FluxVolume          = info{:,'VolumeViaHeight'};
    obj.FluxCrossSection    = info{:,'Area'};
    obj.FitOriginTime       = info{:,'ExperimentStart'};
    obj.FitStartTime        = info{:,'ExperimentStart'} - obj.FitOriginTime;
    obj.FitEndTime          = info{:,'ExperimentEnd'} - obj.FitOriginTime;
    obj.FitVariables        = info{:,'Variable'};
end