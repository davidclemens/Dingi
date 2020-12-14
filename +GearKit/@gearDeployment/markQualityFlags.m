function obj = markQualityFlags(obj)
% MARKQUALITYFLAGS

    import GraphKit.waitForKeyPress
    import GraphKit.Colormaps.cbrewer.cbrewer

    nObj    = numel(obj);

    availableVariables = table();
    for oo = 1:nObj
%         newTable            = obj(oo).variables;
%         obj(oo).data.Info(newTable{1,'Index'}{:}(:,1)).VariableType
        newTable            = obj(oo).data.info;
        newTable{:,'ObjId'}	= oo;
        availableVariables	= cat(1,availableVariables,newTable);
    end
    availableVariables  = availableVariables(availableVariables{:,'Type'} == 'Dependant',:);
    availableVariables{:,'NIndependantVariables'} = cellfun(@numel,availableVariables{:,'IndependantVariableIndex'});
    
    if any(availableVariables{:,'NIndependantVariables'} > 1)
        error('Not implemented yet')
    end
    
    % get unique dependant-independant variable combinations
    [uVariableId,uInd1,uInd]	= unique(cat(2,availableVariables(:,'Id'),table(cellfun(@num2str,availableVariables{:,'IndependantVariableId'},'un',0))),'rows');
    uVariableId                 = cat(2,uVariableId(:,1),availableVariables(uInd1,{'IndependantVariableId','IndependantVariable'}));
    
    % list information about those combinations
    [~,variableInfo]            = DataKit.Metadata.variable.validateId(uVariableId{:,'Id'});
    variableInfo{:,'IndependantVariable'}   = cellfun(@(iv) strjoin({iv(:).Abbreviation},', '),uVariableId{:,'IndependantVariable'},'un',0);
    
    % let the user select which of those combinations to pick
    debugMode   = false;
    if debugMode
        selection       = [1,13,14];
    else
        [selection,ok] = listdlg(...
                            'Name',         'Select variables...',...
                            'PromptString', 'Select variables...',...
                            'ListString',   strcat(variableInfo{:,'Abbreviation'},{' ('},variableInfo{:,'IndependantVariable'},{')'}),...
                            'InitialValue', 1);
        if ~logical(ok)
            return
        end
    end
    % resulting list
    uniqueVariableList	= availableVariables(uInd1(selection),:);
    
    [~,uIndepVariableInd1,uIndepVariableInd2] = unique(cellfun(@num2str,uniqueVariableList{:,'IndependantVariableId'},'un',0));
    uniqueIndependantVariableList = uniqueVariableList{uIndepVariableInd1,'IndependantVariable'};
    nIndependantVariable    = size(uniqueIndependantVariableList,1);
    
    nVariable          = accumarray(uIndepVariableInd2,ones(size(uIndepVariableInd2)));
    nVariableMax       = max(nVariable);
    
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

        xLimits         = cell(spnx,1);
        yLimits         = repmat(NaN(1,2),spnx*spny,1);
        for iv = 1:nIndependantVariable
            col = iv;
            indUniqueVariableList = find(uIndepVariableInd2 == iv);
            for dv = 1:nVariableMax
                row = dv + 1;

                if dv > nVariable(col)
                    continue
                end
                
                hax = hsp(spi(row,col));
                
                maskAvailableVariables  = availableVariables{:,'ObjId'} == oo & ...
                                          availableVariables{:,'Id'} == uniqueVariableList{indUniqueVariableList(dv),'Id'};
                
%                 [poolIdx,variableIdx]	= obj(oo).data.findVariable('Variable.Id',  uniqueVariableList{indUniqueVariableList(dv),'Id'},...
%                                                                     'VariableType', 'Dependant');
% 
%                 data = obj(oo).data.fetchVariableData(poolIdx,variableIdx);
                try
                    data        = obj(oo).fetchData(uniqueVariableList{indUniqueVariableList(dv),'Id'},...
                                    'RelativeTime',         '',...
                                    'GroupBy',              'Variable');
                catch ME
                    switch ME.identifier
                        case 'DataKit:dataPool:fetchData:noRequestedVariableIsAvailable'
                            text(0.5,0.5,'no data',...
                                'Units',        'normalized')
                            continue
                        otherwise
                            rethrow(ME)
                    end
                end

                nSources        = size(data.DepData,1);

                legendEntries   = cell.empty;
                for src = 1:nSources
                    nIndepVariables     = numel(data.IndepData{src});

                    if nIndepVariables > 1
                        error('Not implemented yet.')
                    end

                    meta    = obj(oo).data.Info.VariableMeasuringDevice;

                    XData = data.IndepData{src}{1};
                    YData = data.DepData{src};

                    if numel(XData(:)) < 50
                        marker  = 'o';
                    else
                        marker  = '.';
                    end
                    
                    displayName     = [uniqueVariableList{indUniqueVariableList(dv),'Variable'}.Abbreviation,' (',data.DepInfo.MeasuringDevice(src).DeviceDomain.Abbreviation,')'];
                    plot(hax,XData,YData,...
                        'Tag',              displayName,...
                        'UserData',         cat(2,data.DepInfo.PoolIdx(src),data.DepInfo.VariableIdx(src)),...
                        'Marker',           marker)

                    legendEntries           = cat(1,legendEntries,{displayName});
                    if isempty(xLimits{col})
                        xLimits{col}      	= [nanmin(XData(:)),nanmax(XData(:))];
                    else
                        xLimits{col}      	= [nanmin([xLimits{col}(1);XData(:)]),nanmax([xLimits{col}(2);XData(:)])];
                    end
                    yLimits(spi(row,col),:)	= [nanmin([yLimits(spi(row,col),1);YData(:)]),nanmax([yLimits(spi(row,col),2);YData(:)])];
                end
                legend(hax,legendEntries,...
                    'Location',         'best');
            end
            set(hsp(spi(2:nVariable(col) + 1,col)),...
                'XLim',         xLimits{col} + [-1 1].*0.01.*range(xLimits{col}))
        end
        maskNoData = any(isnan(yLimits),2);
        set(hsp(~maskNoData),...
            {'YLim'},    	num2cell(yLimits(~maskNoData,:) + [-1 1].*0.01.*range(yLimits(~maskNoData,:),2),2))

        TightFig(hfig,hsp(1:spnx*spny),spi,hfig.UserData.PaperPosition,hfig.UserData.MarginOuter,hfig.UserData.MarginInner);

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
            poolIdx     =  hbw.Charts{src,'userData'}{:}(1);
            variableIdx =  hbw.Charts{src,'userData'}{:}(2);
            obj(oo).data.Flag{poolIdx}(:,variableIdx) = hbw.Charts{src,'brushData'}{:}';
        end
        oo = oo + 1;
    end

end

function h = initializeGearDeploymentBrushFigureWindow(Variable)

    [~,uInd1,uInd2]         = unique(cellfun(@num2str,Variable{:,'IndependantVariableId'},'un',0));
    IndependantVariable     = Variable{uInd1,'IndependantVariable'};
    nIndependantVariable    = size(IndependantVariable,1);
    
    nVariable          = accumarray(uInd2,ones(size(uInd2)));
    nVariableMax       = max(nVariable);
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
    clf(hfig,'reset')


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


    spnx     	= nIndependantVariable;
    spny     	= 1 + nVariableMax;
    spi     	= reshape(1:spnx*spny,spnx,spny)';

    yLabels     = {''};
    yLabels     = cat(1,yLabels,strcat(variableInfo{:,'Abbreviation'},{' ('},cellstr(variableInfo{:,'Unit'}),{')'}));

    for col = 1:spnx
        iv = col;
        for row = 1:spny
            dv = row;
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
            if dv > nVariable(iv) + 1
                set(hsp(spi(row,col)),...
                    'Visible',  'off')
            end
%             ylabel(yLabels{dv})
        end
        set(hsp(spi(1:nVariable(col),col)),...
            'XColor',       'none')
        set([hsp(spi(1:nVariable(col),col)).XAxis],...
            'Visible',  	'off')
    end
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
