function varargout = plot(obj,type,varargin)
% PLOT


    import GraphKit.getMaxFigureSize
    import GraphKit.Colormaps.cbrewer.cbrewer


    nvarargin   = numel(varargin);

    if nargin - nvarargin < 2
        type = 'tilt correction';
    end

    % parse Name-Value pairs
    optionName          = {'FontSize','TitleFontSizeMultiplier','LabelFontSizeMultiplier'}; % valid options (Name)
    optionDefaultValue  = {10,1,1}; % default value (Value)
    [FontSize,...
     TitleFontSizeMultiplier,...
     LabelFontSizeMultiplier,...
    ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments


    hsp                         = gobjects();
    hlgnd                       = gobjects();
    hp                          = gobjects();

    cmap                        = cbrewer('qual','Set1',7);
    fOutFigName                 = [type];
    Menubar                     = 'figure';
    Toolbar                     = 'auto';
    maxFigureSize               = getMaxFigureSize('Menubar',Menubar);

    figNums     = 30 + (0:1);
    switch type
        case 'tilt correction'
            fig     = figNums(1);
            hfig    = figure(fig);
            set(hfig,...
                'Visible',      'off');
            clf

            PaperHeight                 = maxFigureSize(2);
            PaperWidth                  = PaperHeight/2;
            PaperPos                    = [PaperWidth PaperHeight];
            MarginOuter                 = 0.5;
            MarginInner                 = 0.5;  % cm

            set(hfig,...
                'Name',                 fOutFigName,...
                'Menubar',              Menubar,...
                'Toolbar',              Toolbar,...
                'PaperSize',            PaperPos,...
                'PaperOrientation',     'Portrait')

            spnx                        = 2;
            spny                        = 4;
            spi                         = reshape(1:spnx*spny,spnx,spny)';

            MarkerColor 	= [0.5 0.5]'.*ones(1,3);
            data            = {obj.velocity,obj.velocityRaw};
            titleString     = {'tilt corrected','raw'};
            viewXYZ         = [diag(ones(1,3));ones(1,3)];
            viewXYZ(2,2)    = -1;
            skipPoints      = 100;

            limits          = cellfun(@(d) cat(2,nanmin(d(1:skipPoints:end,:),[],1)',nanmax(d(1:skipPoints:end,:),[],1)'),data,'un',0);
            limits          = cat(3,limits{:});
            limits          = 1.02.*[-1 1].*max(abs(limits(:)));

          	for col = 1:spnx
                ver = col;
                for row = 1:spny
                    v   = row;
                    hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),...
                                            'NextPlot',                 'add',...
                                            'Layer',                    'top',...
                                            'Box',                      'off',...
                                            'FontSize',                 FontSize,...
                                            'TitleFontSizeMultiplier',  TitleFontSizeMultiplier,...
                                            'LabelFontSizeMultiplier',  LabelFontSizeMultiplier,...
                                            'TitleFontWeight',          'normal',...
                                            'TickDir',                  'out',...
                                            'ColorOrder',               cmap,...
                                            'DataAspectRatio',          ones(1,3));

                        % plot tilt corrected velocity
                        XData   = data{ver}(1:skipPoints:end,1);
                        YData   = data{ver}(1:skipPoints:end,2);
                        ZData   = data{ver}(1:skipPoints:end,3);
                        scatter3(XData,YData,ZData,...
                            'Marker',               '.',...
                            'MarkerEdgeColor',      MarkerColor(ver,:))

                        % plot coordinate system axes
                        s = limits(2);
                        % TODO: i & j change with each timeseries window. Plot all.
                        for win = 1:obj.windowN
                            i = obj.coordinateSystemUnitVectors(1,:,win).*s;
                            j = obj.coordinateSystemUnitVectors(2,:,win).*s;
                            k = obj.coordinateSystemUnitVectors(3,:,win).*s;
                            % new
                            plot3([0,i(1)],[0,i(2)],[0,i(3)],'r','LineWidth',2)
                            plot3([0,j(1)],[0,j(2)],[0,j(3)],'g','LineWidth',2)
                            plot3([0,k(1)],[0,k(2)],[0,k(3)],'b','LineWidth',2)
                        end
                        % old
                        plot3([0,1].*s,[0,0].*s,[0,0].*s,'r','LineWidth',0.5)
                        plot3([0,0].*s,[0,1].*s,[0,0].*s,'g','LineWidth',0.5)
                        plot3([0,0].*s,[0,0].*s,[0,1].*s,'b','LineWidth',0.5)

                        xlim(limits)
                        ylim(limits)
                        zlim(limits)
                        xlabel('u')
                        ylabel('v')
                        zlabel('w')

                        view(viewXYZ(v,:))


                        if row == 1
                            title(titleString{ver})
                        end
%                         if any(row == 1:2)
%                             set(hsp(spi(row,col)),...
%                                 'XTickLabel',   {''},...
%                                 'YTickLabel',   {''})
%                         end
%                         if col == 2 && row < spny
%                             set(hsp(spi(row,col)),...
%                                 'YTickLabel',   {''},...
%                                 'ZTickLabel',   {''})
%                         end
                end
            end
        case 'cross correlation'
            fig     = figNums(2);
            hfig    = figure(fig);
            set(hfig,...
                'Visible',      'off');
            clf

            PaperWidth                  = maxFigureSize(1);
            PaperHeight                 = PaperWidth/2;
            PaperPos                    = [PaperWidth PaperHeight];
            MarginOuter                 = 0.5;
            MarginInner                 = 0.5;  % cm

            set(hfig,...
                'Name',                 fOutFigName,...
                'Menubar',              Menubar,...
                'Toolbar',              Toolbar,...
                'PaperSize',            PaperPos,...
                'PaperOrientation',     'Portrait')

            spnx                        = 1;
            spny                        = 2;
            spi                         = reshape(1:spnx*spny,spnx,spny)';

            data    = {obj.w_.*obj.fluxParameter_(:,1),obj.w_.*obj.fluxParameter_(:,2)};
          	for col = 1:spnx
                for row = 1:spny
                    dat = row;
                    hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),...
                                            'NextPlot',                 'add',...
                                            'Layer',                    'top',...
                                            'Box',                      'off',...
                                            'FontSize',                 FontSize,...
                                            'TitleFontSizeMultiplier',  TitleFontSizeMultiplier,...
                                            'LabelFontSizeMultiplier',  LabelFontSizeMultiplier,...
                                            'TitleFontWeight',          'normal',...
                                            'TickDir',                  'out',...
                                            'ColorOrder',               cmap);

                        % plot tilt corrected velocity
                        XData   = obj.time(1:obj.sampleWindowedN,:);
                        YData   = data{dat};

                        plot(XData,YData,...
                            'Color',        'k')


                        xlabel('time')
                        ylabel('w''C'' (m/s)')
                end
            end
        otherwise
            error('GearKit:eddyFluxAnalysis:plot:unknownPlotType',...
                'unknown plot type')
    end
    TightFig(hfig,hsp,spi,PaperPos,MarginOuter,MarginInner);
    set(hfig,...
        'Visible',      'on');
end
