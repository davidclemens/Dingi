function obj = initializeFigureWindow(obj)

    import GraphKit.Colormaps.cbrewer.cbrewer
    
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

    PaperWidth                  = 22.4;
    PaperHeight                 = 18.05;
    PaperPos                    = [PaperWidth PaperHeight];
    MarginOuter                 = 1;
    MarginInner                 = 1;

    set(hfig,...
        'Name',                 fOutFigName,...
        'Menubar',              Menubar,...
        'Toolbar',              Toolbar,...
        'PaperSize',            PaperPos,...
        'PaperOrientation',     'Portrait')


    spnx     	= 1;
    spny     	= nParameter;
    spi     	= reshape(1:spnx*spny,spnx,spny)';

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
                [time,data,info] = obj(oo).getData(parameterList{par});

        end
    end

end
