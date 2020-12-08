function obj = markQualityFlags(obj)
% MARKQUALITYFLAGS

    import GraphKit.waitForKeyPress
    import GraphKit.Colormaps.cbrewer.cbrewer

    nObj    = numel(obj);

    availableVariables = table();
    for oo = 1:nObj
        newTable            = obj(oo).variables;
        newTable{:,'ObjId'}	= oo;
        availableVariables	= cat(1,availableVariables,newTable);
    end

    [uVariableId,uInd1,uInd]	= unique(availableVariables{:,'Id'});
    [~,variableInfo]   = DataKit.Metadata.variable.validateId(uVariableId);
    
    debugMode   = true;
    if debugMode
        selection       = [1,13,14];
    else
        [selection,ok] = listdlg(...
                            'Name',         'Select variables...',...
                            'PromptString', 'Select variables...',...
                            'ListString',   variableInfo{:,'Abbreviation'},...
                            'InitialValue', 1);
        if ~logical(ok)
            return
        end
    end
    uniqueVariableList	= availableVariables(uInd1(selection),:);
    
    
    nVariable           = size(uniqueVariableList,1);

    % mask selection
    availableVariables	= availableVariables(any(uInd == selection,2),:);
    oo = 1;
    while oo <= nObj
        % initialize figure
        hfig = initializeGearDeploymentBrushFigureWindow(uniqueVariableList);

        % create dataBrushWindow object
        hfig.UserData.BrushWindow    = GraphKit.dataBrushWindow(hfig);

        hsp             = hfig.UserData.SubplotHandles;
        spi             = hfig.UserData.SubplotIndices;
        [spny,spnx]     = size(spi);

        xLimits         = NaN(1,2);
        yLimits         = repmat(NaN(1,2),spnx*spny,1);
        col = 1;
        for par = 1:nVariable
            row = par + 1;

            hax = hsp(spi(row,col));

            maskAvailableVariables = availableVariables{:,'ObjId'} == oo & ...
                                     availableVariables{:,'Id'} == uniqueVariableList{par,'Id'};

            data        = obj(oo).fetchData(availableVariables{maskAvailableVariables,'Id'},...
                            'RelativeTime',         '',...
                            'GroupBy',              'Meas');
                        
            nSources        = size(data.DepData,1);

            legendEntries   = cell.empty;
            for src = 1:nSources
                nIndepVariables     = numel(data.IndepData{src});
                
                if nIndepVariables > 1
                    error('Not implemented yet.')
                end
                
                meta    = data.DepInfo(src);

                % decide on which axis to plot the independant data based
                % on measuring device type
                switch meta.MeasuringDevice.Type
                    case 'BigoPushCore'
                        XData = data.DepData{src};
                        YData = data.IndepData{src}{1};
                    otherwise
                        XData = data.IndepData{src}{1};
                        YData = data.DepData{src};
                end
                
                if numel(XData(:)) < 50
                    marker  = 'o';
                else
                    marker  = '.';
                end
                
                plot(hax,XData,YData,...
                    'Tag',              meta.Variable.Abbreviation,...
                    'UserData',         meta,...
                    'Marker',           marker)

                legendEntries           = cat(1,legendEntries,{meta.Variable.Abbreviation});
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
                    variableIndices    = hbw.Charts{src,'userData'}{:}.variableIndex{:};
                  	sensorIndex         = sensorIndices(hbw.Charts{src,'indChild'});
                    variableIndex      = variableIndices(hbw.Charts{src,'indChild'});
                	obj(oo).sensors(sensorIndex).isOutlier(:,variableIndex) = hbw.Charts{src,'brushData'}{:}';
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

function h = initializeGearDeploymentBrushFigureWindow(Variable)

    nVariable          = size(Variable,1);
    [~,variableInfo]   = DataKit.Metadata.variable.validateId(Variable{:,'Id'});

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
    spny     	= 1 + nVariable;
    spi     	= reshape(1:spnx*spny,spnx,spny)';

    yLabels     = {''};
    yLabels     = cat(1,yLabels,strcat(variableInfo{:,'Abbreviation'},{' ('},cellstr(variableInfo{:,'Unit'}),{')'}));

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
