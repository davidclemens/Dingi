function varargout = plotFlux(obj,variable,groupingParameter,axesProperties)

    hsp     = gobjects();
    heb     = gobjects();
    
    nVariables  = numel(variable);
    
    fluxData    = cat(1,obj.Rates);
    switch groupingParameter
        case 'Gear'
            groups = categorical(strrep(strcat(cellstr(fluxData{:,{'Cruise'}}),'_',cellstr(fluxData{:,{'Gear'}})),'_',' '));
        case 'AreaId'
            groups = fluxData{:,'AreaId'};
        case 'Cruise'
            groups = fluxData{:,'Cruise'};
    end
    [uGroups,~,uGroupsInd]     = unique(groups,'stable');
    nuGroups    = numel(uGroups);
    
    
    spnx	= 1;
    spny	= nVariables;
    spi     = reshape(1:spnx*spny,spnx,spny)';
    
    deviceDomains   = {'Ch1','Ch2'};
    
    xLimits         = NaN(spnx*spny,2);
    yLimits         = NaN(spnx*spny,2);
    yLabelString 	= {variable.Abbreviation};
    
    col = 1;
    for row = 1:spny
        var = row;
        hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),axesProperties{:});
            
            % Plot zero line
            plot([0,nuGroups + 1],zeros(1,2),'k')
            
            % Assemble data
            maskVariable    = fluxData{:,'Variable'} == variable(var);
            XData           = uGroupsInd(maskVariable) + 0.5.*(rand(sum(maskVariable),1) - 0.5);
            YData           = fluxData{maskVariable,'FluxMean'};
            YDataPos        = fluxData{maskVariable,'FluxErrPos'};
            YDataNeg        = fluxData{maskVariable,'FluxErrNeg'};
            
            % Plot data
            heb(spi(row,col)) = errorbar(XData,YData,YDataNeg,YDataPos,'o');

            % Calculate limits
            xLimits(spi(row,col),:) = [min(heb(spi(row,col)).XData(:)),max(heb(spi(row,col)).XData(:))];
            yLimits(spi(row,col),:) = [min(heb(spi(row,col)).YData(:) - heb(spi(row,col)).YNegativeDelta(:)),max(heb(spi(row,col)).YData(:) + heb(spi(row,col)).YPositiveDelta(:))];
            
            % Add labels
            yLabelString{var} = cat(2,yLabelString{var},' (',char(fluxData{find(maskVariable,1),'FluxUnit'}),')');
            ylabel(hsp(spi(row,col)),...
                yLabelString(var))
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
    yLim = arrayfun(@(r) 0.05.*[-1 1].*range(yLimits(spi(r,1:spnx),:)) + [nanmin([0,yLimits(spi(r,1:spnx),1)]),nanmax([0,yLimits(spi(r,1:spnx),2)])],1:spny,'un',0)';
    set(hsp(spi(1:spny,1)),...
        {'YLim'},   yLim)
    set(hsp(spi(1:spny,1:spnx)),...
        'XLim',   [0.5,nuGroups + 0.5])
    
    % Set axis labels
    set(hsp(spi(spny,1)).XAxis,...
        'TickValues',           1:nuGroups,...
        'TickLabels',           cat(1,cellstr(uGroups),{''}),...
        'TickLabelRotation',    60)
    set(cat(1,hsp(spi(1:spny - 1,1)).XAxis),...
        'TickValues',           1:nuGroups,...
        'TickLabels',           repmat({''},nuGroups + 1,1))
    
    % Set grid
    for row = 1:spny
        plot(hsp(spi(row,1)),reshape(cat(1,repmat(double(uGroups)',2,1) - 0.5,NaN(1,nuGroups)),[],1),repmat(cat(1,yLim{row}',NaN),nuGroups,1),...
            'Color',        0.8.*ones(1,3))
    end
end