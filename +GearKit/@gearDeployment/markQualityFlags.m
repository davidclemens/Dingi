function markQualityFlags(obj)
% MARKQUALITYFLAGS

    import GraphKit.waitForKeyPress
    import GraphKit.Colormaps.cbrewer.cbrewer

    nObj            = numel(obj);
    RelativeTime    = '';
    
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
        yLimits         = NaN(spnx*spny,2);
        for iv = 1:nIndependantVariable
            col = iv;
            indUniqueVariableList = find(uIndepVariableInd2 == iv);
            for dv = 1:nVariableMax
                row = dv + 1;

                if dv > nVariable(col)
                    continue
                end
                
                % initialize
                legendEntries   = cell.empty;
                
                % select current axes handle
                hax = hsp(spi(row,col));
                
                % fetch data
                try
                    data        = obj(oo).fetchData(uniqueVariableList{indUniqueVariableList(dv),'Id'},...
                                    'RelativeTime',         RelativeTime,...
                                    'GroupBy',              'Variable');
                catch ME
                    switch ME.identifier
                        case 'DataKit:dataPool:fetchData:noRequestedVariableIsAvailable'
                            % print no data label on axis
                            text(hax,0.5,0.5,'no data',...
                                'Units',        'normalized')
                            
                            if isempty(xLimits{col})
                                xLimits{col}	= hax.XLim;
                            else
                                xLimits{col}	= [nanmin([xLimits{col}(1);hax.XLim(1)]),nanmax([xLimits{col}(2);hax.XLim(2)])];
                            end
                            continue
                        otherwise
                            rethrow(ME)
                    end
                end

                nSources        = size(data.DepData,1);

                for src = 1:nSources
                    nIndepVariables     = numel(data.IndepData{src});

                    if nIndepVariables > 1
                        error('Not implemented yet.')
                    end

                    XData           = data.IndepData{src}{1};
                    YData           = data.DepData{src};
                    FData           = data.Flags{src} == 'MarkedRejected'; % dataFlag

                    if numel(XData(:)) < 50
                        marker  = 'o';
                    else
                        marker  = '.';
                    end
                    
                    displayName     = [uniqueVariableList{indUniqueVariableList(dv),'Variable'}.Abbreviation,' (',data.DepInfo.MeasuringDevice(src).DeviceDomain.Abbreviation,')'];
                    
                    htmp = plot(hax,XData,YData,...
                        'Tag',              displayName,...
                        'UserData',         cat(2,data.DepInfo.PoolIdx(src),data.DepInfo.VariableIdx(src)),...
                        'Marker',           marker,...
                        'LineWidth',        2);
                    htmp.MarkerFaceColor    = htmp.MarkerEdgeColor;
                    htmp.BrushData          = double(FData');

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
            {'YLim'},    	num2cell(yLimits(~maskNoData,:) + [-1 1].*0.05.*range(yLimits(~maskNoData,:),2),2))

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

        % retrieve indices and brush data
        poolIdx         = cat(1,hbw.Charts{:,'userData'}{:});
        variableIdx     = poolIdx(:,2);
        poolIdx         = poolIdx(:,1);
        brushData       = cellfun(@find,hbw.Charts{:,'brushData'},'un',0);
        nBrushData      = cellfun(@numel,brushData);
        
        % grow vectors to match brush data
        poolIdxAll      = arrayfun(@(n,p) p.*ones(n,1),nBrushData,poolIdx,'un',0);
        poolIdxAll      = cat(1,poolIdxAll{:});
        variableIdxAll	= arrayfun(@(n,v) v.*ones(n,1),nBrushData,variableIdx,'un',0);
        variableIdxAll	= cat(1,variableIdxAll{:});
        sampleIdx       = reshape(cat(2,brushData{:}),[],1);
        
       	newFlags        = 3; % flag id to be set ('manually rejected')
        
        % write flags to the gearDeployment instance
        obj(oo).data    = setFlag(obj(oo).data,poolIdxAll,sampleIdx,variableIdxAll,newFlags,1);
        
        oo = oo + 1;
    end
    close(hfig);
    %%{
    fprintf('Saving to disk ...\n');
    for oo = 1:nObj
        obj(oo).MatFile.Properties.Writable = true;
        obj(oo).MatFile.obj = obj(oo);
        obj(oo).MatFile.Properties.Writable = false;
    end
    fprintf('Saving to disk ... done\n');
    %}
    
    fprintf('All done\n');
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
    cmap                        = cmap(2:end,:); % remove red as it is similar to the marking color
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
    PaperPos                    = maxFigureSize.*[1/2 1];
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
    
%     hlnk	= repmat(linkprop(gobjects(),''),1,nIndependantVariable);
    for col = 1:spnx
        iv = col;
        indDv = [0;find(uInd2 == iv)];
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
                                    'YMinorTick',               'on',...
                                    'ColorOrder',               cmap);
            if row > 1
                switch char(IndependantVariable{iv})
                    case 'Time'
                        hsp(spi(row,col)).XAxis = matlab.graphics.axis.decorator.DatetimeRuler;
                    otherwise
                end 
            end
            if dv > nVariable(col) + 1
                set(hsp(spi(row,col)),...
                    'Visible',  'off')
            end
            if dv == nVariable(col) + 1
                xlabel(char(IndependantVariable{iv}))
            end
            if row > 1 && row <= nVariable(col) + 1 
                ylabel(yLabels{indDv(dv) + 1}) 
            end
        end
        set(hsp(spi(1:nVariable(col),col)),...
            'XColor',       'none')
        set([hsp(spi(1:nVariable(col),col)).XAxis],...
            'Visible',  	'off')
        
        hlnk(col)    = linkprop(hsp(spi(2:nVariable(col) + 1,col)),{'XLim'});
    end

    hfig.UserData   = struct(...
                        'SubplotHandles',   hsp,...
                        'SubplotIndices',   spi,...
                        'PaperPosition',    PaperPos,...
                        'MarginOuter',      MarginOuter,...
                        'MarginInner',      MarginInner,...
                        'PropertyLinks',    hlnk);

    h = hfig;
end
