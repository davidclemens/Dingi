function varargout = plotCalibrations(obj)

    import GraphKit.Colormaps.cm

    if numel(obj) > 1
        error('Dingi:GearKit:gearDeployment:plotCalibrations:invalidShape',...
          'Only works in a scalar context.')
    end

    maskNonIdentityCalibrations = ~cellfun(@(f) strcmp(func2str(f),func2str(@(t,x) x)),obj.data.Index{:,'Calibration'});
    nNonIdentityCalibrations    = sum(maskNonIdentityCalibrations);

    nonIdentityCalibrations     = obj.data.Index(maskNonIdentityCalibrations,:);

    % initialize figure
    hfig        = figure(98);
    set(hfig,...
       	'Visible',      'on');
    clf
    set(hfig,...
        'name', 'calibrations')

    hsp                         = gobjects();

    spnx                        = ceil(nNonIdentityCalibrations/2);
    spny                        = ceil(nNonIdentityCalibrations/spnx);
    spi                         = reshape(1:spnx*spny,spnx,spny)';

    n = 100;
    for col = 1:spnx
        for row = 1:spny
            cal     = spi(row,col);
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',         'add');
                if cal <= nNonIdentityCalibrations
                    dp          = nonIdentityCalibrations{cal,'DataPool'};
                    varDep      = nonIdentityCalibrations{cal,'VariableIndex'};
                    varIndep    = obj.data.Index{obj.data.Index{:,'DataPool'} == dp & ...
                                                 obj.data.Index{:,'VariableType'} == 'Independent' & ...
                                                 obj.data.Index{:,'Variable'} == 'Time','VariableIndex'};

                    md          = nonIdentityCalibrations{cal,'MeasuringDevice'};
                   	maskCal     = obj.calibration{:,'Type'} == char(md.Type) & ...
                                  obj.calibration{:,'SerialNumber'} == md.SerialNumber;

                    XData1  = obj.data.fetchVariableData(dp,varIndep,'ReturnRawData',true,'ForceCellOutput',false);
                    YData1  = obj.data.fetchVariableData(dp,varDep,'ReturnRawData',true,'ForceCellOutput',false);
                    ZData1  = obj.data.fetchVariableData(dp,varDep,'ReturnRawData',false,'ForceCellOutput',false);
                    XData2  = obj.calibration{maskCal,'CalibrationTime'};
                    YData2  = obj.calibration{maskCal,'Signal'};
                    ZData2  = obj.calibration{maskCal,'Value'};

                    XData1Info   = obj.data.Info(dp).Variable(varIndep);
                    YData1Info   = obj.data.Info(dp).VariableRaw(varDep);
                    ZData1Info   = obj.data.Info(dp).Variable(varDep);
                    nData   = numel(XData1);
                    if nData > 1e3
                        step    = round(nData/1e3);
                        XData1  = XData1(1:step:end);
                        YData1  = YData1(1:step:end);
                        ZData1  = ZData1(1:step:end);
                    end

                    scatter3(XData1,YData1,ZData1,'.k')
                    hcalpoints = scatter3(XData2,YData2,ZData2,[],datenum(XData2),...
                                    'Marker',           'o',...
                                    'MarkerFaceColor',  'r',...
                                    'MarkerEdgeColor',  'k');
                    view([0 0])

                    xlabel([XData1Info.Abbreviation,' (',XData1Info.Unit,')'])
                    ylabel(['raw (',YData1Info.Abbreviation,', ',YData1Info.Unit,')'])
                    zlabel(['calibr. (',ZData1Info.Abbreviation,', ',ZData1Info.Unit,')'])
                    title(char(obj.data.Info(dp).VariableMeasuringDevice(varDep).Type))

                    XData2  = linspace(nanmin(XData1(:)),nanmax(XData1(:)),n);
                    YData2  = linspace(nanmin(YData1(:)),nanmax(YData1(:)),n);
                    [XDataGrid,YDataGrid] = ndgrid(XData2,YData2);

                    func    = obj.data.Info(dp).VariableCalibrationFunction{varDep};
                    ZData2  = reshape(func(datenum(XDataGrid(:)),YDataGrid(:)),n,n);
                    surf(XDataGrid,YDataGrid,ZData2,ZData2)
                    shading interp
                    caxis([min(datenum(ZData2(:))),max(datenum(ZData2(:)))])
                    cm('thermal');
                end
        end
    end
end
