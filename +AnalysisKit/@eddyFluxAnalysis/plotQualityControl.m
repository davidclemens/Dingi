function varargout = plotQualityControl(obj,fig,datasetName,varargin)

    import AnalysisKit.Metadata.eddyFluxAnalysisDataFlag

    nargoutchk(0,1)
    
    validateattributes(obj,{'AnalysisKit.eddyFluxAnalysis'},{'scalar'})
    
    if nargin == 3
        flagNames       = eddyFluxAnalysisDataFlag.listMembers;
        flagNames       = flagNames(~ismember(flagNames,'undefined'));
    elseif nargin == 4
        flagNames =     varargin{1};
        if ischar(flagNames)
            flagNames = {flagNames};
        end
    end
    
    hfig    = figure(fig);
    set(hfig,...
        'Visible',      'on');
    clf

    nSamples        = size(obj.([datasetName,'QC']),1);
    nSeries         = size(obj.([datasetName,'QC']),2);
    
    spnx                        = 1;
    spny                        = nSeries;
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
                                    'FontSize',                 12,...
                                    'LabelFontSizeMultiplier',  10/12);
        end
    end

    nFlags          = numel(flagNames);
    marker          = {'o','+','*','.','x','s','d','^','v','>','<','p','h'};
    XData   = obj.TimeQC;
    YDataQC = obj.([datasetName,'QC']);
    YDataDS = obj.([datasetName,'DS']);
    for col = 1:spnx
        for row = 1:spny
            ser  = row;
            hax = hsp(spi(row,col));
            
            hp = plot(hax,XData,YDataQC(:,ser),...
                'Color',        'k');
            
            hsc = gobjects();
            for ff = 1:nFlags
                flag	= isFlag(obj.(['Flag',datasetName]),flagNames{ff});
                
                hsc(ff) = scatter(hax,XData(flag(:,ser)),YDataDS(flag(:,ser),ser),...
                    'Marker',       marker{mod(ff - 1,numel(marker)) + 1},...
                    'SizeData',     pi*(2/25.4*72)^2);
            end
            
            if row == 1
                title(hax,obj.Parent.gearId,...
                    'Interpreter',      'none')
            end
            if row == spny
                xlabel(hax,'time')
            end
            
            legend(hax,hsc,flagNames,...
                'Location',     'eastoutside')
        end
    end
    
    set(hsp(spi(1:spny - 1,1:spnx)),...
        'XTickLabel',   {})
    
    lnk = 1;
    hlnk(lnk) = linkprop(hsp(spi(1:spny,1:spnx)),{'XLim'});
    
    hfig.UserData   = hlnk;
    if nargout == 1
        varargout{1} = hfig;
    end
end