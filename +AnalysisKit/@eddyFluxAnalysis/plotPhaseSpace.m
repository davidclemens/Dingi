function varargout = plotPhaseSpace(data,dData,d2Data,uniCrit,theta)
    %%
    import GraphKit.Colormaps.cm
    
    ind     = 1;
    nbins   = 100;
    [dataN,dataEdges]       = histcounts(data,nbins);
    dataEdges               = mean([dataEdges(1:end - 1);dataEdges(2:end)]);
    [dDataN,dDataEdges]     = histcounts(dData,nbins);
    dDataEdges              = mean([dDataEdges(1:end - 1);dDataEdges(2:end)]);
    [d2DataN,d2DataEdges]	= histcounts(d2Data,nbins);
    d2DataEdges          	= mean([d2DataEdges(1:end - 1);d2DataEdges(2:end)]);
        
    markerHistogram = 'k';
    markerScatter   = '.k';
    
	cmap = cat(1,ones(1,3),cm('deep',255));
        
    %%
    hsp = gobjects();

    hfig = figure(4);
    clf
	% export figure parameters
    PaperWidth  = 17;              	% cm
    PaperHeight = 5/2*PaperWidth;  	% cm
    MarginOuter	= .2;               % cm
    MarginInner	= .2;               % cm
    set(hfig,...
        'Name',                 '',...
        'Visible',              'on',...
        'DockControls',         'off',...
        'PaperUnits',           'centimeter',...
        'PaperOrientation',     'portrait',...
        'PaperPosition',        [0,0,PaperWidth,PaperHeight],...
        'PaperSize',            [PaperWidth,PaperHeight]);
    clf
    
    
    %             scatter3(Data.Data(:,ind),dData.Data(:,ind)./g,d2Data.Data(:,ind)./g,'.k')
    %             xlabel('u (m/s)')
    %             ylabel('g^{-1} du/dt (s^{-1})')
    %             zlabel('g^{-1} d^2u/dt^2 (s^{-1})')

    spnx    = 2;
    spny    = 5;
    spi    	= reshape(1:spnx*spny,spnx,spny)';



    row     = 2;
    col     = 1;
    hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                        	'NextPlot',         'add',...
                            'XTickLabel',       {});
        XData   = data;
        YData   = dData;
        scatter(XData,YData,markerScatter)
        drawPointDensity(XData,YData,nbins)
        drawEllipse(uniCrit(1),uniCrit(2),theta(1))
        
        colormap(cmap);
%         
%         maskOutlier = (cos(theta).*(XData - x0) + sin(theta).*(YData - y0)).^2./a.^2 + ...
%                       (sin(theta).*(XData - x0) - cos(theta).*(YData - y0)).^2./b.^2 > 1;
%         scatter(XData(maskOutlier),YData(maskOutlier),'.r')
        
        ylabel('dx')

    row     = 3;
    col     = 1;
    hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                          	'NextPlot',         'add');                        
        XData   = data;
        YData   = d2Data;
        
        scatter(XData,YData,markerScatter)
        drawPointDensity(XData,YData,nbins)
        drawEllipse(uniCrit(1),uniCrit(3),theta(2))
        
        colormap(cmap);
%         
%         maskOutlier = (cos(theta).*(XData - x0) + sin(theta).*(YData - y0)).^2./a.^2 + ...
%                       (sin(theta).*(XData - x0) - cos(theta).*(YData - y0)).^2./b.^2 > 1;
%         scatter(XData(maskOutlier),YData(maskOutlier),'.r')
        
        xlabel('x')
        ylabel('d^2x')

    row     = 5;
    col     = 1;
    hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                         	'NextPlot',         'add');
                        
        XData = dData;
        YData = d2Data;
        scatter(XData,YData,markerScatter)
        drawPointDensity(XData,YData,nbins)        
        drawEllipse(uniCrit(2),uniCrit(3),theta(3))
        
        colormap(cmap);
%         
%         maskOutlier = (cos(theta).*(XData - x0) + sin(theta).*(YData - y0)).^2./a.^2 + ...
%                       (sin(theta).*(XData - x0) - cos(theta).*(YData - y0)).^2./b.^2 > 1;
%         scatter(XData(maskOutlier),YData(maskOutlier),'.r')
        
        xlabel('dx')
        ylabel('d^2x')

    row     = 1;
    col     = 1;
    hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                            'NextPlot',         'add',...
                            'YScale',           'log',...
                            'XTickLabel',       {});
        bar(dataEdges,dataN,markerHistogram)
        ylabel('#')

    row     = 2;
    col     = 2;
    hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                            'NextPlot',         'add',...
                            'XScale',           'log',...
                            'XTickLabel',       {},...
                            'YTickLabel',       {});
        barh(dDataEdges,dDataN,markerHistogram)

    row     = 3;
    col     = 2;
    hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                            'NextPlot',         'add',...
                            'XScale',           'log',...
                            'YTickLabel',       {});
        barh(d2DataEdges,d2DataN,markerHistogram)       
        xlabel('#')

    row     = 5;
    col     = 2;
    hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                            'NextPlot',         'add',...
                            'XScale',           'log',...
                            'YTickLabel',       {});
        barh(d2DataEdges,d2DataN,markerHistogram)
        xlabel('#')

    row     = 4;
    col     = 1;
    hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                            'NextPlot',         'add',...
                            'YScale',           'log',...
                            'XTickLabel',       {});
        bar(dDataEdges,dDataN,markerHistogram)
        ylabel('#')
        
	row     = 1;
    col     = 2;
	hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                            'Visible',          'off');
        
	row     = 4;
    col     = 2;
	hsp(spi(row,col)) = subplot(spny,spnx,spi(row,col),...
                            'Visible',          'off');
        
        
        
    ii          = 1;
    hlnk(ii)    = linkprop(hsp([1,3,5]),'XLim');
    ii          = ii + 1;
    hlnk(ii)    = linkprop(hsp([7,9]),'XLim');
    ii          = ii + 1;
    hlnk(ii)    = linkprop(hsp([4,6,10]),'XLim');
    ii          = ii + 1;
    hlnk(ii)    = linkprop(hsp([3,4]),'YLim');
    ii          = ii + 1;
    hlnk(ii)    = linkprop(hsp([5,6]),'YLim');
    ii          = ii + 1;
    hlnk(ii)    = linkprop(hsp([9,10]),'YLim');
    ii          = ii + 1;
            
    hfig.UserData = hlnk;
    
    TightFig(hfig,hsp(1:spnx*spny),spi,[PaperWidth PaperHeight],MarginOuter,MarginInner);

    function drawEllipse(a,b,theta)
        t       = linspace(0,2*pi,100);
        x0      = 0;
        y0      = 0;
        x       = x0 + a*cos(t)*cos(theta) - b*sin(t)*sin(theta);
        y       = y0 + b*sin(t)*cos(theta) + a*cos(t)*sin(theta);
        plot(x,y,'r')
    end
    function drawPointDensity(x,y,nbins)
        [N,Xedges,Yedges] = histcounts2(x,y,nbins);
        [XGrid,YGrid] = ndgrid(Xedges(1:end - 1) + 0.5.*diff(Xedges),Yedges(1:end - 1) + 0.5.*diff(Yedges));
        hp = pcolor(XGrid,YGrid,N);
        shading interp
        set(hp,...
            'MarkerEdgeColor',  'none',...
            'FaceAlpha',        0.75)
    end
end
