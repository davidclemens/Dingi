function markQualityFlags(obj)
% MARKQUALITYFLAGS

    import GraphKit.waitForKeyPress
    import GraphKit.Colormaps.cbrewer.cbrewer

    nObj    = numel(obj);

    availableParameters = table();
    for oo = 1:nObj
        newTable            = obj(oo).parameters;
        newTable{:,'ObjId'}	= oo;
        availableParameters	= cat(1,availableParameters,newTable);
    end

    [itemList,uInd1,uInd]	= unique(availableParameters{:,'Parameter'});

    debugMode   = false;
    if debugMode
        selection       = [1,13,14];
    else
        [selection,ok] = listdlg(...
                            'Name',         'Select parameters...',...
                            'PromptString', 'Select parameters...',...
                            'ListString',   itemList,...
                            'InitialValue', 1);
        if ~logical(ok)
            return
        end
    end
    uniqueParameterList	= availableParameters(uInd1(selection),:);
    nParameter          = size(uniqueParameterList,1);

    % mask selection
    availableParameters	= availableParameters(any(uInd == selection,2),:);
    oo = 1;
    while oo <= nObj
        % initialize figure
        hfig = initializeGearDeploymentBrushFigureWindow(uniqueParameterList);

        % create dataBrushWindow object
        hfig.UserData.BrushWindow    = GraphKit.dataBrushWindow(hfig);

        hsp             = hfig.UserData.SubplotHandles;
        spi             = hfig.UserData.SubplotIndices;
        [spny,spnx]     = size(spi);

        xLimits         = NaN(1,2);
        yLimits         = repmat(NaN(1,2),spnx*spny,1);
        col = 1;
        for par = 1:nParameter
            row = par + 1;

            hax = hsp(spi(row,col));

            maskAvailableParamters = availableParameters{:,'ObjId'} == oo & ...
                                     availableParameters{:,'ParameterId'} == uniqueParameterList{par,'ParameterId'};

            [time,data,info] = obj(oo).getData(availableParameters{maskAvailableParamters,'ParameterId'},...
                                'RelativeTime',         'h');
            nSources        = size(data,1);


            legendEntries   = cell.empty;
            for src = 1:nSources
                XData = time{src};
                YData = data{src};

                meta    = info(src);
                meta.inSensorData           = availableParameters{maskAvailableParamters,'InSensorData'};
                meta.inAnalyticalSampleData	= availableParameters{maskAvailableParamters,'InAnalyticalSampleData'};
                meta.sensorIndex            = availableParameters{maskAvailableParamters,'SensorIndex'};
                meta.parameterIndex       	= availableParameters{maskAvailableParamters,'ParameterIndex'};


                switch info(src).dataSourceType
                    case 'analyticalSample'
                        marker  = 'o';
                        sourceId    = regexprep(cellstr(obj(oo).analyticalSamples{:,'SampleId'}),'\d+$','');
                        meta.analyticalSampleMask   = obj(oo).analyticalSamples{:,'ParameterId'} == uniqueParameterList{par,'ParameterId'} & ...
                                                      obj(oo).analyticalSamples{:,'Subgear'} == meta.dataSourceDomain & ...
                                                      sourceId == meta.dataSourceId;

                    case 'sensor'
                        marker  = '.';
                        meta.analyticalSampleMask   = logical.empty;
                    otherwise
                        error('GearKit:gearDeployment:markQualtiyFlags:unknownDataSourceType',...
                            '''%s'' is an unknown data source type.',info(src).dataSourceType);
                end



                plot(hax,XData,YData,...
                    'Tag',              char(info(src).name),...
                    'UserData',         meta,...
                    'Marker',           marker)


                legendEntries   = cat(1,legendEntries,info(src).name);
                xLimits                 = [nanmin([xLimits(1);XData(:)]),nanmax([xLimits(2);XData(:)])];
                yLimits(spi(row,col),:)	= [nanmin([yLimits(spi(row,col),1);YData(:)]),nanmax([yLimits(spi(row,col),2);YData(:)])];
            end
            legend(hax,legendEntries,...
                'Location',         'best');
        end
        set(hsp(spi(2:end,1)),...
            'XLim',         xLimits + [-1 1].*0.01.*range(xLimits))
        maskNoData = any(isnan(yLimits),2);
        set(hsp(~maskNoData),...
            {'YLim'},    	num2cell(yLimits(~maskNoData,:) + [-1 1].*0.01.*range(yLimits(~maskNoData,:),2),2))

        TightFig(hfig,hsp(1:spnx*spny),spi,hfig.UserData.PaperPosition,hfig.UserData.MarginOuter,hfig.UserData.MarginInner);


        % TODO: extract and save brushed data from
        % hfig.UserData.BrushWindow object
        waitForValidKeyPress = true;
        while waitForValidKeyPress
            keyName = waitForKeyPress;
            switch keyName
                case 'space'
                    waitForValidKeyPress = false;



                otherwise
                    waitForValidKeyPress = true;
            end
        end

        hbw     = hfig.UserData.BrushWindow;
        hbw.EnableBrushing = 'off';

        % retrieve brush data and write it to the gearDeployment instance
        for src = 1:size(hbw.Charts,1)
            switch char(hbw.Charts{src,'userData'}{:}.dataSourceType)
                case 'sensor'
                    sensorIndices    	= hbw.Charts{src,'userData'}{:}.sensorIndex{:};
                    parameterIndices    = hbw.Charts{src,'userData'}{:}.parameterIndex{:};
                  	sensorIndex         = sensorIndices(hbw.Charts{src,'indChild'});
                    parameterIndex      = parameterIndices(hbw.Charts{src,'indChild'});
                	obj(oo).sensors(sensorIndex).isOutlier(:,parameterIndex) = hbw.Charts{src,'brushData'}{:}';
                case 'analyticalSample'
                    rowMask     = hbw.Charts{src,'userData'}{:}.analyticalSampleMask;
                    if ~ismember('isOutlier',obj(oo).analyticalSamples.Properties.VariableNames)
                        obj(oo).analyticalSamples{:,'isOutlier'} = false;
                    end
                    obj(oo).analyticalSamples{rowMask,'isOutlier'} = hbw.Charts{src,'brushData'}{:}';
                otherwise
                    error('not implemented yet.')
            end
        end

%         mf = matfile(obj(oo).dataFolderInfo.saveFile,'Writable',true);
%         mf.BIGOs(oo)

        oo = oo + 1;
    end

end

function h = initializeGearDeploymentBrushFigureWindow(Parameter)

    nParameter          = size(Parameter,1);
    [~,parameterInfo]   = DataKit.validateParameterId(Parameter{:,'ParameterId'});

    hsp                         = gobjects();
    hlgnd                       = gobjects();
    hp                          = gobjects();
    Menubar                     = 'figure';
    Toolbar                     = 'auto';
    cmap                        = cbrewer('qual','Set1',7);
    cMapAlternating             = [  7 170 188;...
                                   127 127 127]./255;
    FontSize                    = 16;
    LabelFontSizeMultiplier     = 1;
    TitleFontSizeMultiplier     = 1;
    LineWidthBold               = 1.5;
    LineWidth                   = 1;

    % initialize figure
    fig         = 88;
    fOutFigName	= 'mark quality flags';
    hfig        = figure(fig);
    set(hfig,...
        'Visible',      'on');
    clf


    maxFigureSize   = GraphKit.getMaxFigureSize(...
                        'Units',        'centimeters',...
                        'Menubar',     	Menubar,...
                        'Toolbar',   	Toolbar);
    PaperWidth                  = 22.4;
    PaperHeight                 = 18.05;
    PaperPos                    = maxFigureSize.*[1/3 1];
    MarginOuter                 = 0.5;
    MarginInner                 = 0;

    set(hfig,...
        'Name',                 fOutFigName,...
        'Menubar',              Menubar,...
        'Toolbar',              Toolbar,...
        'PaperSize',            PaperPos,...
        'PaperOrientation',     'Portrait')


    spnx     	= 1;
    spny     	= 1 + nParameter;
    spi     	= reshape(1:spnx*spny,spnx,spny)';

    yLabels     = {''};
    yLabels     = cat(1,yLabels,strcat(parameterInfo{:,'Abbreviation'},{' ('},cellstr(parameterInfo{:,'Unit'}),{')'}));

    for col = 1:spnx
        for row = 1:spny
            par = row;
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',                 'add',...
                                    'Layer',                    'top',...
                                    'Box',                      'off',...
                                    'FontSize',                 FontSize,...
                                    'TitleFontSizeMultiplier',  TitleFontSizeMultiplier,...
                                    'LabelFontSizeMultiplier',  LabelFontSizeMultiplier,...
                                    'TitleFontWeight',          'normal',...
                                    'TickDir',                  'out',...
                                    'XMinorTick',               'on',...
                                    'YMinorTick',               'on');
            ylabel(yLabels{par})
        end
    end
    set(hsp(spi(1:spny - 1,:)),...
        'XColor',       'none')
    set([hsp(spi(1:spny - 1,:)).XAxis],...
        'Visible',  	'off')
    hlnk    = linkprop(hsp(2:spnx*spny),{'XLim'});

    hfig.UserData   = struct(...
                        'SubplotHandles',   hsp,...
                        'SubplotIndices',   spi,...
                        'PaperPosition',    PaperPos,...
                        'MarginOuter',      MarginOuter,...
                        'MarginInner',      MarginInner,...
                        'PropertyLinks',    hlnk);

    h = hfig;
end
