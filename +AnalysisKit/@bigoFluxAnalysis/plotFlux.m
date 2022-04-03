function varargout = plotFlux(obj,variable,axesProperties)

    hsp     = gobjects();
    hsc    	= gobjects();
    heb     = gobjects();
    
    nVariables  = numel(variable);
    nObj        = numel(obj);
    
    spnx                        = nObj;
    spny                        = nVariables;
    spi                         = reshape(1:spnx*spny,spnx,spny)';
    
    deviceDomains   = {'Ch1','Ch2'};
    
    xLimits         = NaN(spnx*spny,2);
    yLimits         = NaN(spnx*spny,2);
    yLabelString 	= cell(spny,1);
    xLabelString 	= cell(spnx,1);
    for col = 1:spnx
        oo = col;
        for row = 1:spny
            var = row;
            
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),axesProperties{:});
                    
                maskVariable    = obj(oo).Rates{:,'Variable'} == variable(var);
                XData = categorical(cellstr(obj(oo).Rates{maskVariable,'DeviceDomain'}));
                YData = obj(oo).Rates{maskVariable,'FluxMean'};
                YDataPos = obj(oo).Rates{maskVariable,'FluxErrPos'};
                YDataNeg = obj(oo).Rates{maskVariable,'FluxErrNeg'};
                
                heb(spi(row,col)) = errorbar(XData,YData,YDataNeg,YDataPos,'o');
                
%                 hsc(spi(row,col)) = scatter(XData,YData);

                xLimits(spi(row,col),:) = [min(heb(spi(row,col)).XData(:)),max(heb(spi(row,col)).XData(:))];
                yLimits(spi(row,col),:) = [min(heb(spi(row,col)).YData(:) - heb(spi(row,col)).YNegativeDelta(:)),max(heb(spi(row,col)).YData(:) + heb(spi(row,col)).YPositiveDelta(:))];
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
    set(hsp(spi(1:spny,1)),...
        {'YLim'},   arrayfun(@(r) [nanmin(yLimits(spi(r,1:spnx),1)),nanmax(yLimits(spi(r,1:spnx),2))],1:spny,'un',0)')
    set(hsp(spi(1:spny,1:spnx)),...
        'XLim',   [nanmin([0;xLimits(:,1)]),nanmax(xLimits(:,2))])
    
    % Set axis labels
    tmp     = [hsp(spi(1:spny,1)).YAxis];
    set([tmp.Label],...
        {'String'},     {cellstr(variable)})
end