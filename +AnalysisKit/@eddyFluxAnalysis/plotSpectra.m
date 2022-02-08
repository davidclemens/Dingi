function varargout = plotSpectra(obj,window)

    nargoutchk(0,1)

    if nargin == 1
        window = 1:obj.WindowN;
    end

    C1m         = 2.5e-3;
    U1m         = 0.2; % (m/s)
    vFriction   = sqrt(C1m)*U1m; % u* (m/s)
    h           = 0.3; % height above sediment (m)
    epsilon     = vFriction^3/h;

    eddySzSpace	= [2*pi*((1.3e-6)^3/epsilon)^(1/4),h]; % (m)
    eddySzTime	= [(eddySzSpace(1)^2/epsilon)^(1/3),h/vFriction]; % (s)



    fig     = 45;
    hfig    = figure(fig);
    set(hfig,...
        'Visible',      'on');
    clf

    spnx                        = 1;
    spny                        = 5;
    spi                         = reshape(1:spnx*spny,spnx,spny)';

    for win = 1:numel(window)
        [f,vpsW(:,win)]    = vps(obj.Velocity(:,win,3),obj.Frequency);
        [f,vpsFP1(:,win)]  = vps(obj.FluxParameter(:,win,1),obj.Frequency);
        [f,vpsFP2(:,win)]  = vps(obj.FluxParameter(:,win,2),obj.Frequency);
        [f,csWFP1(:,win)]  = cs(obj.W_(:,win),obj.FluxParameter_(:,win,1),obj.Frequency);
        [f,csWFP2(:,win)]  = cs(obj.W_(:,win),obj.FluxParameter_(:,win,2),obj.Frequency);
    end

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

    axes(hsp(spi(1,1)));
        XData = f;
        YData = vpsW;
        plot(XData,YData)

    axes(hsp(spi(2,1)));
        YData = vpsFP1;
        plot(XData,YData)

    axes(hsp(spi(3,1)));
        YData = vpsFP2;
        plot(XData,YData)

    axes(hsp(spi(4,1)));
        YData = csWFP1;
        plot(XData,YData)
        YData = csWFP2;
        plot(XData,YData)

    axes(hsp(spi(5,1)));
        YData = flipud(cumsum(flipud(csWFP1)));
        plot(XData,YData)
        YData = flipud(cumsum(flipud(csWFP2)));
        plot(XData,YData)

    hlnk = linkprop(hsp(:),'XLim');

    if nargout == 1
        varargout{1} = obj;
    end

    function [f,vpxx] = vps(x,fs)

        [pxx,f] = pwelch(x,[],[],[],fs,'onesided');
        vpxx    = movmean(pxx.*f,5);
    end
    function [f,pxy] = cs(x,y,fs)

        [pxy,f] = cpsd(x,y,[],[],[],fs,'onesided');
        pxy     = abs(pxy);
    end

    
end
