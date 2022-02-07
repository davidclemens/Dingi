function varargout = calculateCospectrum(obj)

    nargoutchk(0,1)

    wins    = 1:15;
%     [pxy,f] = cpsd(reshape(obj.W_(:,wins),[],1),reshape(obj.FluxParameter_(:,wins,1),[],1),hanning(obj.WindowLength),[],[],obj.Frequency);
%     [pxy,f] = cpsd(obj.W_(:,wins),obj.FluxParameter_(:,wins,1),hanning(obj.WindowLength),obj.WindowLength/2,[],obj.Frequency,'mimo');
    [pxy1,f1] = cpsd(obj.W_(:,wins),obj.FluxParameter_(:,wins,1),[],[],[],obj.Frequency,'onesided');
    [pxy2,f2] = cpsd(obj.W_(:,wins),obj.FluxParameter_(:,wins,2),[],[],[],obj.Frequency,'onesided');

    pxy1     = real(pxy1);
    pxy2     = real(pxy2);

    figure(10)
    clf
    YData   = cumsum(pxy1,1);
    hp = plot(1./f1,YData);
    hax = gca;
    set(hp,...
        {'Color'}, num2cell(parula(size(YData,2)),2))

    hax.XScale = 'log';
    hax.YDir = 'reverse';

    figure(11)
    clf

    df  = diff(f1);
    XData   = datetime(mean(obj.Time(:,wins)),'ConvertFrom','datenum');
    YData   = 24.*60.*60.*cat(1,sum(pxy1(1:end - 1,:).*df),sum(pxy2(1:end - 1,:).*df))';
    hb = bar(XData,YData,1);
    xlabel('UTC')
    ylabel('O_2 Fluss (mmol m^{-2} d^{-1})')
    PaperPos    = [15,6];
    hax = gca;
    hfig = gcf;
    set(hfig,...
        'PaperSize',    PaperPos,...
        'PaperPosition',[0,0,PaperPos])
    set(hax,...
        'FontSize', 12,...
        'TickDir',  'out',...
        'TitleFontSizeMultiplier', 1,...
        'LabelFontSizeMultiplier', 10/12)
    TightFig(hfig,hax,1,PaperPos,0.5,0.1);
    legend('Pico1','Pico2','location','best')


    print(hfig,'~/Desktop/flux.pdf','-dpdf')
    
    if nargout == 1
        varargout{1} = obj;
    end
end
