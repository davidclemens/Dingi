function varargout = plotQualityControl(obj,fig)

    import AnalysisKit.Metadata.eddyFluxAnalysisDataFlag

    nargoutchk(0,1)
    
    hfig    = figure(fig);
    set(hfig,...
        'Visible',      'on');
    clf

    spnx                        = 1;
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
                                    'TickDir',                  'in');
        end
    end

    flagNames       = eddyFluxAnalysisDataFlag.listMembers;
    flagNames       = flagNames(~ismember(flagNames,'undefined'));
    flagNamesCat    = categorical({eddyFluxAnalysisDataFlag(flagNames).Abbreviation});
    nFlags          = numel(flagNames);
    
    flagCounts      = zeros(nFlags,3 + obj.FluxParameterN);
    flagGroupLabels = {'u','v','w','O2 1','O2 2'};
    for ff = 1:nFlags
        flagCounts(ff,1:3)    	= sum(isFlag(obj.FlagVelocity,flagNames{ff}));
        flagCounts(ff,4:end)    = sum(isFlag(obj.FlagFluxParameter,flagNames{ff}));
    end
    
    row = 1;
    col = 1;
    axes(hsp(spi(row,col)));
        bar(flagNamesCat,100.*flagCounts./size(obj.TimeDS,1))
        legend(flagGroupLabels)
        ylabel('fraction of dataset (%)')
    
    if nargout == 1
        varargout{1} = hfig;
    end
end