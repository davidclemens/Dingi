function varargout = plotQualityControlStatistics(obj,fig)

    import AnalysisKit.Metadata.eddyFluxAnalysisDataFlag

    nargoutchk(0,1)
    
    hfig    = figure(fig);
    set(hfig,...
        'Visible',      'on');
    clf

    nObj                        = numel(obj);
    spnx                        = nObj;
    spny                        = 1;
    spi                         = reshape(1:spnx*spny,spnx,spny)';
    
    hsp     = gobjects(spnx*spny,1);
    % Create axes
    for col = 1:spnx
        for row = 1:spny
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',                 'add',...
                                    'Layer',                    'top',...
                                    'Box',                      'off',...
                                    'TitleFontWeight',          'normal',...
                                    'TickDir',                  'in',...
                                    'XScale',                   'log',...
                                    'FontSize',                 12,...
                                    'LabelFontSizeMultiplier',  10/12);
        end
    end

    flagNames       = eddyFluxAnalysisDataFlag.listMembers;
    flagNames       = flagNames(~ismember(flagNames,'undefined'));
    flagNamesCat    = categorical({eddyFluxAnalysisDataFlag(flagNames).Abbreviation});
    nFlags          = numel(flagNames);
    
    for col = 1:spnx
       	oo  = col;
        for row = 1:spny
            hax = hsp(spi(row,col));
            
            flagCounts      = zeros(nFlags,3 + obj(oo).NFluxParameters);
            flagGroupLabels = {'u','v','w','O2 1','O2 2'};
            for ff = 1:nFlags
                flagCounts(ff,1:3)    	= sum(isFlag(obj(oo).FlagVelocity,flagNames{ff}));
                flagCounts(ff,4:end)    = sum(isFlag(obj(oo).FlagFluxParameter,flagNames{ff}));
            end
            
            line(hax,[1 3 10]'.*ones(1,nFlags),flagNamesCat,...
                'Color',    'k')
            
            hb = barh(hax,flagNamesCat,100.*flagCounts./size(obj(oo).TimeQC,1),...
                'EdgeColor',        'w',...
                'BarWidth',         1);
            title(hax,obj(oo).Parent.gearId,...
                'Interpreter',      'none')
            xlabel(hax,'fraction of dataset (%)')
            
            legend(hax,hb,flagGroupLabels,...
                'Location',     'best')
        end
    end
    
    set(hsp(spi(1:spny,2:spnx)),...
        'YTickLabel',   {})
    
    lnk = 1;
    hlnk(lnk) = linkprop(hsp(spi(1:spny,1:spnx)),'XLim');
    
    hsp(1).XLim(2) = 100;
        
    
    hfig.UserData   = hlnk;
    if nargout == 1
        varargout{1} = hfig;
    end
end