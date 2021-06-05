function varargout = plotTracerPath(obj,fig)
    
    makeVectorComplex = @(vec) complex(vec(:,1),vec(:,2));

    getAngle = @(vecA,vecB) rad2deg(real(log((vecB./vecA).*(abs(vecA)./abs(vecB)))./1i));

    hfig    = figure(fig);
    set(hfig,...
        'Visible',      'on');
    clf
    
    spnx                        = 3;
    spny                        = numel(obj);
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
    
    XLimits = NaN(1,2);
    YLimits = NaN(1,2);
    RLimits = NaN(1,2);
    VLimits = zeros(1,2);
    for row = 1:spny
        
        oo = row;
        
        TData   = obj(oo).TimeDS;
        VData   = movmean(obj(oo).VelocityQC(:,1:2),5*obj(oo).Frequency,1,'omitnan');
        dist	= makeVectorComplex(VData.*(1/obj(oo).Frequency));
        speed   = movmean(abs(makeVectorComplex(VData)),15.*60.*obj(oo).Frequency,'omitnan');
        speedWarn   = speed < 0.005;
        
        AData   = getAngle(dist(1:end - 1),dist(2:end));
        AData   = movmean(AData,5.*60.*obj(oo).Frequency,'omitnan');
        XData   = cumsum(real(dist),'omitnan');
        YData   = cumsum(imag(dist),'omitnan');

        % Number of cumulative full rotations
        RData   = round(cumsum(AData,'omitnan')./360,1);

        markerInterval = minutes(1);
        ind     = 1:obj(oo).Frequency*seconds(markerInterval):numel(XData);

        col = 1;
        hax = hsp(spi(row,col));

            plot(hax,XData,YData,'k');
            
            XLimits = [min([XLimits(1);XData(:)]),max([XLimits(2);XData(:)])];
            YLimits = [min([YLimits(1);YData(:)]),max([YLimits(2);YData(:)])];

            scatter(hax,XData(ind),YData(ind),[],RData(ind),...
                'Marker',               'o',...
                'MarkerEdgeColor',      'none',...
                'MarkerFaceColor',      'flat');
            scatter(hax,XData(speedWarn),YData(speedWarn),[],[1 0 0],...
                'Marker',               'o',...
                'MarkerEdgeColor',      'none',...
                'MarkerFaceColor',      'flat');

            colorbar(hax);

            title(hax,obj(oo).Parent.gearId,'Interpreter','none')
            xlabel(hax,'X (m)')
            ylabel(hax,'Y (m)')
            
            set(hax,...
                'DataAspectRatio',          ones(1,3))
        
        col = 2;
        hax = hsp(spi(row,col));
            scatter(hax,TData(~speedWarn(1:end - 1)),RData(~speedWarn(1:end - 1)),'.k')
            scatter(hax,TData(speedWarn(1:end - 1)),RData(speedWarn(1:end - 1)),'.r');
            
            RLimits = [min([RLimits(1);RData(:)]),max([RLimits(2);RData(:)])];
            
            xlabel(hax,'time')
            ylabel(hax,'# rotations')
        
        col = 3;
        hax = hsp(spi(row,col));
            scatter(hax,TData(~speedWarn),speed(~speedWarn),'.k')
            scatter(hax,TData(speedWarn),speed(speedWarn),'.r');
            
            VLimits = [min([VLimits(1);speed(:)]),max([VLimits(2);speed(:)])];
            
            xlabel(hax,'time')
            ylabel(hax,'horiz. vel. (m/s)')
    end
    
    set(hsp(spi(1:spny,1)),...
        'XLim',     XLimits,...
        'YLim',     YLimits)
    set(hsp(spi(1:spny,2)),...
        'YLim',     RLimits)
    set(hsp(spi(1:spny,3)),...
        'YLim',     VLimits)
    
    iilnk = 1;
    hlnk(iilnk) = linkprop(hsp(spi(1:spny,1)),{'XLim','YLim'});
    iilnk = iilnk + 1;
    hlnk(iilnk) = linkprop(hsp(spi(1:spny,2)),{'YLim'});
    iilnk = iilnk + 1;
    hlnk(iilnk) = linkprop(hsp(spi(1:spny,3)),{'YLim'});
    iilnk = iilnk + 1;
    for row = 1:spny
        hlnk(iilnk) = linkprop(hsp(spi(row,2:3)),{'XLim'});
        iilnk = iilnk + 1;
    end
    
    hfig.UserData = hlnk;
    
    if nargout == 1
        varargout{1} = hfig;
    end
end