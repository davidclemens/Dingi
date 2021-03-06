function readAnalyticalSamples(obj)
% READANALYTICALSAMPLES

    import DataKit.importTableFile
    import DebuggerKit.Debugger.printDebugMessage

    printDebugMessage('Info','Reading %s analytical sample(s) data...',char(obj.gearType))

    try
        filename    = [obj.dataFolderInfo.rootFolder,'/',char(obj.cruise),'_',char(obj.gearType),'_analyticalSamples.xlsx'];
        tbl         = importTableFile(filename);

        if isempty(tbl)
            % no analytical data found
            return
        end
        mask        = all(tbl{:,{'Cruise','Gear'}} == [obj.cruise,obj.gear],2);

        % append time data
        tbl     = tbl(mask,:);
        tbl     = outerjoin(tbl,obj.protocol,...
                                    'Keys',             {'Subgear','SampleId'},...
                                    'MergeKeys',        true,...
                                    'RightVariables',   {'Time','TimeRelative'},...
                                    'Type',             'left');

        uMeasuringDevices   = unique(tbl(:,{'MeasuringDeviceType','Subgear'}),'rows');
        nuMeasuringDevices  = size(uMeasuringDevices,1);
        for mdt = 1:nuMeasuringDevices
            
            printDebugMessage('Verbose','Reading analytical data for measuring device %u of %u: %s %s ...',mdt,nuMeasuringDevices,char(uMeasuringDevices{mdt,'MeasuringDeviceType'}),char(uMeasuringDevices{mdt,'Subgear'}))
    
            maskTbl     = all(tbl{:,{'MeasuringDeviceType','Subgear'}} == uMeasuringDevices{mdt,:},2);
            maskTblInd 	= find(maskTbl);
            if sum(maskTbl) == 0
                continue
            end
            subs    = [];
            [uRows,indepidx,subs(:,1)]	= unique(cellstr(tbl{maskTbl,{'SampleId'}}));
            [uCols,~,subs(:,2)]         = unique(tbl{maskTbl,{'ParameterId'}});

            switch uMeasuringDevices{mdt,'MeasuringDeviceType'}
                case 'BigoPushCore'
                    data                = tbl{maskTblInd(indepidx),'Depth'};
                    variables           = {'Depth'};
                    variableOrigin      = {0};
                    worldDomain         = GearKit.worldDomain.Sediment;
                case {'BigoSyringeSampler','BigoCapillarySampler'}
                    data                = seconds(tbl{maskTblInd(indepidx),'TimeRelative'});
                    variables           = {'Time'};
                    maskProtocol1       = obj.protocol{:,'MeasuringDeviceType'} == char(uMeasuringDevices{mdt,{'MeasuringDeviceType'}}) & ...
                                          obj.protocol{:,'Subgear'} == uMeasuringDevices{mdt,'Subgear'};
                    controlUnit         = obj.protocol{find(maskProtocol1,1),'ControlUnit'};
                    maskExperimentStart	= all(obj.protocol{:,{'Subgear','SampleId','Event'}} == {char(controlUnit),'System','Experiment Start'},2);
                    if sum(maskExperimentStart) ~= 1
                        error('Dingi:GearKit:gearDeployment:readAnalyticalSamples:invalidExperimentStart',...
                            'There is no or too many experiment start events found for %s.',cat(2,char(obj.cruise),' ',char(obj.gear),' ',char(uMeasuringDevices{mdt,'Subgear'})))
                    end
                    variableOrigin      = {obj.protocol{maskExperimentStart,'Time'}};
                    worldDomain         = GearKit.worldDomain.BenthicWaterColumn;
                case 'BigoManualSampling'
                    maskProtocol1       = obj.protocol{:,'Subgear'} == uMeasuringDevices{mdt,'Subgear'};
                    controlUnit         = obj.protocol{find(maskProtocol1,1),'ControlUnit'};
                    maskExperimentStart	= all(obj.protocol{:,{'Subgear','SampleId','Event'}} == {char(controlUnit),'System','Experiment Start'},2);
                    if sum(maskExperimentStart) ~= 1
                        error('Dingi:GearKit:gearDeployment:readAnalyticalSamples:invalidExperimentStart',...
                            'There is no or too many experiment start events found for %s.',cat(2,char(obj.cruise),' ',char(obj.gear),' ',char(uMeasuringDevices{mdt,'Subgear'})))
                    end
                    variableOrigin      = {obj.protocol{maskExperimentStart,'Time'}};
                    variables           = {'Time'};
                    data                = seconds(obj.timeRecovery - variableOrigin{:});
                    worldDomain         = GearKit.worldDomain.BenthicWaterColumn;                    
                case 'BigoNiskinBottle'
                    variables           = {'Time'};
                    maskExperimentStart	= all(obj.protocol{:,{'SampleId','Event'}} == {'System','Experiment Start'},2);
                    variableOrigin      = {mean(obj.protocol{maskExperimentStart,'Time'})};
                    data                = repmat(seconds(obj.timeRecovery - variableOrigin{1}),numel(indepidx),1);
                    worldDomain         = GearKit.worldDomain.BenthicWaterColumn;
                otherwise
                    error('Dingi:GearKit:gearDeployment:readAnalyticalSamples:measuringDeviceTypeNotImplemented',...
                        'Reading analytical sample(s) for measuring device type ''%s'' is not implemented.',char(uMeasuringDevices{mdt,'MeasuringDeviceType'}))
            end
            data            = cat(2,data,accumarray(subs,tbl{maskTbl,{'Value'}},[numel(uRows),numel(uCols)],@nanmean,NaN));
            variables       = cat(2,variables,cellstr(DataKit.Metadata.variable.fromProperty('Id',uCols)'));
            variableType    = cat(2,{'Independent'},repmat({'Dependent'},1,size(data,2) - 1));

           	measuringDevice                     = GearKit.measuringDevice();
            measuringDevice.Type                = char(uMeasuringDevices{mdt,'MeasuringDeviceType'});
            measuringDevice.SerialNumber        = char(uMeasuringDevices{mdt,'Subgear'});
            measuringDevice.MountingLocation    = char(uMeasuringDevices{mdt,'Subgear'});
            measuringDevice.WorldDomain         = worldDomain;
            measuringDevice.DeviceDomain        = GearKit.deviceDomain.fromProperty('Abbreviation',char(uMeasuringDevices{mdt,'Subgear'}));

            variableOrigin          = cat(2,variableOrigin,repmat({0},1,size(data,2) - 1));
            variableMeasuringDevice	= repmat(measuringDevice,1,size(data,2));

            obj.data.addVariable(variables,data,...
                'VariableType',             variableType,...
                'VariableOrigin',           variableOrigin,...
                'VariableMeasuringDevice',	variableMeasuringDevice);
        end
    catch ME
        switch ME.identifier
            case 'MATLAB:xlsread:FileNotFound'
                printDebugMessage('Info','No file with name ''%s'' found',filename)
            otherwise
                rethrow(ME)
        end
    end

    printDebugMessage('Info','Reading %s analytical sample(s) data... done',char(obj.gearType))
end
