function varargout = plotFits(obj,variable,showConfidenceInterval,axesProperties)
    
    nargoutchk(0,2)
    
    hsp     = gobjects();
    hp      = gobjects();
    
    nVariables  = numel(variable);
    
    spnx                        = numel(obj);
    spny                        = nVariables;
    spi                         = reshape(1:spnx*spny,spnx,spny)';
    
    n = 100;
    xLimits         = NaN(spnx*spny,2);
    yLimits         = NaN(spnx*spny,2);
    yLabelString 	= cell(spny,1);
    xLabelString 	= cell(spnx,1);
    for col = 1:spnx
        oo = col;
        for row = 1:spny
            var = row;
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),axesProperties{:});
                maskFitsInd     = find(obj(oo).FitVariables == variable(var));
                [hasRate,maskRateInd] = ismember(maskFitsInd,obj(oo).RateIndex);
                nFits       = numel(maskFitsInd);
                if isempty(maskFitsInd)
                    text(0.5,0.5,'no data','Units','normalized')
                    continue
                end
                deviceDomains   = obj(oo).FitDeviceDomains(maskFitsInd);

                xFitData        = NaN(n,nFits);
                yFitData        = NaN(n,nFits);
                yFitDataDelta   = NaN(n,nFits);
                for ff = 1:nFits
                    xData  	= obj(oo).Time(:,maskFitsInd(ff));
                    yData   = obj(oo).FluxParameter(:,maskFitsInd(ff));
                    exclude	= obj(oo).Exclude(:,maskFitsInd(ff));

                    % Extract limits
                    xLimits(spi(row,col),:) = [nanmin([xLimits(spi(row,col),1);xData]), nanmax([xLimits(spi(row,col),2);xData])];
                    yLimits(spi(row,col),:) = [nanmin([yLimits(spi(row,col),1);yData(~exclude)]), nanmax([yLimits(spi(row,col),2);yData(~exclude)])];
                    
                    if sum(~exclude) > 20
                        marker = '.';
                    else
                        marker = 'o';
                    end
                    
                    % Plot excluded values
                    scatter(hsp(spi(row,col)),xData(exclude),yData(exclude),...
                        'Marker',           '+',...
                        'MarkerEdgeColor',  0.8.*ones(1,3))
                    % Plot included values
                    scatter(hsp(spi(row,col)),xData(~exclude),yData(~exclude),...
                        'Marker',           marker,...
                        'MarkerEdgeColor',  hsp(spi(row,col)).ColorOrder(ff,:))

                    % Evaluate fits, if available
                    if hasRate(ff)
                        xFitPlotRange   = [nanmin(xData(~exclude)),nanmax(xData(~exclude))];
                        xFitPlotRange   = 0.1.*range(xFitPlotRange).*[-1 1] + xFitPlotRange;
                        xFitData(:,ff)  = linspace(xFitPlotRange(1),xFitPlotRange(2),n)';
                        [yFitData(:,ff),yFitDataDelta(:,ff)] = polyval(obj(oo).Fits(maskRateInd(ff)).Coeff,xFitData(:,ff),obj(oo).Fits(maskRateInd(ff)).ErrEst);
                        
                        % Plot fit confidence interval
                        if showConfidenceInterval
                            patch(...
                                'XData',        cat(1,xFitData(:,ff),flipud(xFitData(:,ff))),...
                                'YData',        cat(1,yFitData(:,ff),flipud(yFitData(:,ff))) + cat(1,-yFitDataDelta(:,ff),flipud(yFitDataDelta(:,ff))),...
                                'FaceColor',    hsp(spi(row,col)).ColorOrder(ff,:),...
                                'FaceAlpha',    0.2,...
                                'EdgeColor',    'none')
                        end
                    end
                end
                
                % Plot fits, set colors and legend entries
                hp(spi(row,col),1:nFits) = plot(hsp(spi(row,col)),xFitData,yFitData);
                set(hp(spi(row,col),1:nFits),...
                    {'Color'},    num2cell(hsp(spi(row,col)).ColorOrder(1:nFits,:),2))
                legendLabels = strcat({deviceDomains.Abbreviation}');
                legend(hp(spi(row,col),1:nFits),legendLabels,...
                    'Location',     'best')
                
                yLabelString{row}   = [obj(oo).FitVariables(maskFitsInd(ff)).Abbreviation,' (µM)'];
                
            if row == 1
                title(hsp(spi(row,col)),obj(oo).Parent.gearId,...
                    'Interpreter',  'none')
            end
        end
     	xLabelString{col}   = ['t (',obj(oo).TimeUnit,')'];
    end
    hfig    = hsp(spi(1,1)).Parent;
    
    % Set axis property links
    iilnk   = 1;
    for row = 1:spny
        hlnk(iilnk) = linkprop(hsp(spi(row,1:spnx)),{'YLim'});
        iilnk       = iilnk + 1;
    end
    for col = 1:spnx
        hlnk(iilnk) = linkprop(hsp(spi(1:spny,col)),{'XLim'});
        iilnk       = iilnk + 1;
    end
    hfig.UserData = hlnk;
    
    % Set axis limits (as links are set, only one axis in each link set
    % must have its limits set).
    set(hsp(spi(1:spny,1)),...
        {'YLim'},   arrayfun(@(r) [nanmin(yLimits(spi(r,1:spnx),1)),nanmax(yLimits(spi(r,1:spnx),2))],1:spny,'un',0)')
    set(hsp(spi(1:spny,1:spnx)),...
        'XLim',   [nanmin([0;xLimits(:,1)]),nanmax(xLimits(:,2))])
    
    % Set axis labels
    tmp     = [hsp(spi(1:spny,1)).YAxis];
    set([tmp.Label],...
        {'String'},     yLabelString)
    tmp     = [hsp(spi(spny,1:spnx)).XAxis];
    set([tmp.Label],...
        {'String'},     xLabelString)
    
    % Remove redundant tick labels
    for col = 2:spnx
        set(hsp(spi(1:spny,col)),'YTickLabel',{''})
    end
    for row = 1:spny - 1
        set(hsp(spi(row,1:spnx)),'XTickLabel',{''})
    end
        
    
    if nargout == 1
        varargout{1} = hsp;
    elseif nargout == 2
        varargout{1} = hsp;
        varargout{2} = spi;
    end
end
