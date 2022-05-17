function varargout = plotFluxes(obj,fig,varargin)

    hfig    = figure(fig);
    set(hfig,...
        'Visible',      'on');
    clf

    spnx                        = 1;
    spny                        = 3;
    spi                         = reshape(1:spnx*spny,spnx,spny)';

    for col = 1:spnx
        for row = 1:spny
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),...
                                    'NextPlot',                 'add',...
                                    'Layer',                    'top',...
                                    'Box',                      'off',...
                                    'TitleFontWeight',          'normal',...
                                    'TickDir',                  'in',...
                                    'XScale',                   'log');
        end
    end
    t   = reshape(obj.TimeRS,[],1);
    w_  = reshape(obj.VelocityDT(:,:,3),[],1); % m/s
    fp_ = reshape(obj.FluxParameterDT(:,:,1),[],1); % µmol/L
    axes(hsp(spi(1,1)));
        XData = t;
        YData = w_;
        plot(XData,YData)

    axes(hsp(spi(2,1)));
        YData = fp_;
        plot(XData,YData)

    axes(hsp(spi(3,1)));
        YData = w_.*fp_.*(3600*24);
        plot(XData,YData)
        
    hlnk = linkprop(hsp(:),'XLim');
end