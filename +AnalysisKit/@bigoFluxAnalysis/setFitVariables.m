function setFitVariables(obj)

    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFitVariables:settingFitVariables',...
        'Info','Setting fit variables ...')
    
    info                = obj.Parent.data.info;
    info.DeviceDomain   = cat(1,info{:,'MeasuringDevice'}.DeviceDomain);
    info.WorldDomain    = cat(1,info{:,'MeasuringDevice'}.WorldDomain);
    info                = outerjoin(info,obj.Parent.HardwareConfiguration.DeviceDomainMetadata,...
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
	printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFitVariables:onlyMuConcentrationsUsed',...
            'Warning','Only variables with concentrations in µM are implemented to be fit right now.')
	
	if sum(mask) == 0
        printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFitVariables:noVariableFound',...
            'Warning','There was no variable for fitting found.')
	end
    
    info    = info(mask,:);
    
    % Set properties
    obj.PoolIndex           = info{:,'DataPoolIndex'};
    obj.VariableIndex       = info{:,'VariableIndex'};
    obj.FitDeviceDomains    = info{:,'DeviceDomain'};
    obj.FluxVolume          = info{:,'VolumeViaHeight'};
    obj.FluxCrossSection    = info{:,'Area'};
    obj.FitOriginTime       = info{:,'ExperimentStart'};
    obj.FitVariables        = info{:,'Variable'};
    
    printDebugMessage('Dingi:AnalysisKit:bigoFluxAnalysis:setFitVariables:settingFitVariables',...
        'Info','Setting fit variables ... done')
end