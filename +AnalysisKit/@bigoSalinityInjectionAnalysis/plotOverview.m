function varargout = plotOverview(obj,axesProperties)
    
    nargoutchk(0,2)
    
    hsp     = gobjects();
    
    variables =         {'SalinityAbsolute','TemperatureConservative',  'Density'};
    variableUnits =     {'g kg^{-1}',       '°C',                       'g cm^{-3}'};
    nVariables = numel(variables);
    
    spnx	= numel(obj);
    spny	= nVariables;
    spi     = reshape(1:spnx*spny,spnx,spny)';
    
    xLimits         = NaN(spnx*spny,2);
    yLimits         = NaN(spnx*spny,2);
    yLabelString    = cell(spny,1);
    for col = 1:spnx
        oo = col;
        for row = 1:spny
            var = row;
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),axesProperties{:});

                hp      = gobjects();
                for dd = 1:obj(oo).NDeviceDomains
                    % Assemble data
                    Exclude         = obj(oo).Exclude(:,dd);
                    XData           = obj(oo).Time(~Exclude,dd);
                    YData           = obj(oo).(variables{var})(~Exclude,dd);

                    % Plot data
                    hp(dd)  = plot(hsp(spi(row,col)),XData,YData,'.');
                    
                end
                % Calculate limits
                xLimits(spi(row,col),:) = [min(cat(2,hp.XData)),max(cat(2,hp.XData))];
                yLimits(spi(row,col),:) = [min(cat(2,hp.YData)),max(cat(2,hp.YData))];
                
                % Add labels
                yLabelString{var} = [variables{var},' (',variableUnits{var},')'];
                ylabel(hsp(spi(row,col)),...
                    yLabelString(var))
                if row == 1
                    title(obj(oo).Parent.gearId,...
                        'Interpreter',      'none')
                end
        end
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
    yLim = arrayfun(@(r) 0.05.*[-1 1].*range(yLimits(spi(r,1:spnx),:)) + [nanmin([yLimits(spi(r,1:spnx),1)]),nanmax([yLimits(spi(r,1:spnx),2)])],1:spny,'un',0)';
    set(hsp(spi(1:spny,1)),...
        {'YLim'},   yLim)
    xLim = 0.05.*[-1 1].*range(xLimits,2) + [nanmin(xLimits(:,1)),nanmax(xLimits(:,2))];
    xLim = [nanmin(xLim(:,1)),nanmax(xLim(:,2))];
    set(hsp,...
        'XLim',   xLim)
    
 	set(cat(1,hsp(spi(1:spny,2:spnx)).YAxis),...
        'TickLabels',       {},...
        'Label',            text())
 	set(cat(1,hsp(spi(1:spny - 1,1:spnx)).XAxis),...
        'TickLabels',       {},...
        'Label',            text())
    xLabelString = strcat({'time ('},{obj.TimeUnit},{')'});
    for col = 1:spnx
        xlabel(hsp(spi(spny,col)),xLabelString{col})
    end
    
    if nargout == 1
        varargout{1} = hsp;
    elseif nargout == 2
        varargout{1} = hsp;
        varargout{2} = spi;
    end
end
