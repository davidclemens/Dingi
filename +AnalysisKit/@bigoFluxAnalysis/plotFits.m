function varargout = plotFits(obj,variable,showConfidenceInterval,showR2,omitCruiseIdInTitle,axesProperties)
    
    nargoutchk(0,3)
    
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
    uDeviceDomains  = table(GearKit.deviceDomain.empty,[],[],'VariableNames',{'DeviceDomain','Color','Target'});
    for col = 1:spnx
        oo = col;
        for row = 1:spny
            var = row;
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),axesProperties{:});
                maskFitsInd     = find(obj(oo).FitVariables == variable(var));
                yLabelString{row}   = [variable(var).Abbreviation,' (µM)'];
                [hasRate,maskRateInd] = ismember(maskFitsInd,obj(oo).RateIndex);
                nFits       = numel(maskFitsInd);
                if isempty(maskFitsInd)
                    text(hsp(spi(row,col)),0.5,0.5,'no data',...
                        'Units',                'normalized',...
                        'VerticalAlignment',    'middle',...
                        'HorizontalAlignment',  'center')
                    continue
                end
                
                deviceDomains  	= obj(oo).FitDeviceDomains(maskFitsInd);
                imDevDom        = ismember(deviceDomains,uDeviceDomains{:,'DeviceDomain'});
                
                % Append to unique device domain list if necessary
                if any(~imDevDom)
                    newDeviceDomains        = unique(deviceDomains(~imDevDom),'stable');
                    newDeviceDomainColors   = hsp(spi(row,col)).ColorOrder(size(uDeviceDomains,1) + 1:size(uDeviceDomains,1) + numel(newDeviceDomains),:);
                    uDeviceDomains          = cat(1,uDeviceDomains,table(newDeviceDomains,newDeviceDomainColors,cell(numel(newDeviceDomains),1),'VariableNames',{'DeviceDomain','Color','Target'}));
                end
                
                [~,uDeviceDomainsInd]	= ismember(deviceDomains,uDeviceDomains{:,'DeviceDomain'});
                deviceDomainColors      = uDeviceDomains{uDeviceDomainsInd,'Color'};

                xFitData        = NaN(n,nFits);
                yFitData        = NaN(n,nFits);
                yFitDataDelta   = NaN(n,nFits);
                r2String        = cell.empty;
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
                    if hasRate(ff)
                        scatter(hsp(spi(row,col)),xData(~exclude),yData(~exclude),...
                            'Marker',           marker,...
                            'MarkerEdgeColor',  deviceDomainColors(ff,:))
                    else
                        % Use a star marker if the data has no fit/rate
                        scatter(hsp(spi(row,col)),xData(~exclude),yData(~exclude),...
                            'Marker',           '*',...
                            'MarkerEdgeColor',  deviceDomainColors(ff,:))
                    end

                    % Evaluate fits, if available
                    if hasRate(ff)
                        xFitPlotRange   = [nanmin(xData(~exclude)),nanmax(xData(~exclude))];
                        xFitPlotRange   = 0.1.*range(xFitPlotRange).*[-1 1] + xFitPlotRange;
                        xFitData(:,ff)  = linspace(xFitPlotRange(1),xFitPlotRange(2),n)';
                        [yFitData(:,ff),yFitDataDelta(:,ff)] = polyval(obj(oo).Fits(maskRateInd(ff)).Coeff,xFitData(:,ff),obj(oo).Fits(maskRateInd(ff)).ErrEst);
                        
                        % Plot fit confidence interval
                        if showConfidenceInterval
                            patch(hsp(spi(row,col)),...
                                'XData',        cat(1,xFitData(:,ff),flipud(xFitData(:,ff))),...
                                'YData',        cat(1,yFitData(:,ff),flipud(yFitData(:,ff))) + cat(1,-yFitDataDelta(:,ff),flipud(yFitDataDelta(:,ff))),...
                                'FaceColor',    deviceDomainColors(ff,:),...
                                'FaceAlpha',    0.2,...
                                'EdgeColor',    'none')
                        end
                        r2String{ff,1} = ['\color[rgb]{',regexprep(num2str(deviceDomainColors(ff,:)),'\s+',','),'}',num2str(obj(oo).Fits(maskRateInd(ff)).R2,'%.1f')];
                    end
                end
                if showR2
                    r2String(cellfun(@isempty,r2String)) = [];
                    r2String = strjoin(r2String,'\\color[rgb]{0,0,0}, ');
                    text(hsp(spi(row,col)),1,1,['R2: ',r2String,' '],...
                        'Interpreter',          'tex',...
                        'Units',                'normalized',...
                        'VerticalAlignment',    'top',...
                        'HorizontalAlignment',  'right',...
                        'FontSize',             8)
                end
                
                % Plot fits, set colors and legend entries
                hp(spi(row,col),1:nFits) = plot(hsp(spi(row,col)),xFitData,yFitData);
                uDeviceDomains{uDeviceDomainsInd,'Target'} = num2cell(reshape(hp(spi(row,col),1:nFits),[],1),2); % Add target handles to device domains for the legend to refer to
                set(hp(spi(row,col),1:nFits),...
                    {'Color'},    num2cell(deviceDomainColors,2))
                
            if row == 1
                if omitCruiseIdInTitle
                    titleString = char(obj(oo).Parent.gear);
                else
                    titleString = strjoin(cellstr([obj(oo).Parent.cruise,obj(oo).Parent.gear]),' ');
                end
                title(hsp(spi(row,col)),titleString,...
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
    yLimits = arrayfun(@(r) [nanmin(yLimits(spi(r,1:spnx),1)),nanmax(yLimits(spi(r,1:spnx),2))],1:spny,'un',0)';
    if showR2
        % Make room for the R2 values
        verticalR2Space = 0.2;
        yLimits = cellfun(@(l) [l(1),l(2) + verticalR2Space*range(l)],yLimits,'un',0);
    end
    yLimits(cellfun(@(x) any(isnan(x)),yLimits)) = {[0,1]};
    set(hsp(spi(1:spny,1)),...
        {'YLim'},   yLimits)
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
        
    % Add legend
    legendLabels = strcat({uDeviceDomains{:,'DeviceDomain'}.Abbreviation}');
    hlgd = legend(cat(1,uDeviceDomains{:,'Target'}{:}),legendLabels,...
        'Location',     'best',...
        'Box',          'off');
    
    if nargout == 1
        varargout{1} = hsp;
    elseif nargout == 2
        varargout{1} = hsp;
        varargout{2} = spi;
    elseif nargout == 3
        varargout{1} = hsp;
        varargout{2} = spi;
        varargout{3} = hlgd;
    end
end
