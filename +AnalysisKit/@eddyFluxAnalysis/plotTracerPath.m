function varargout = plotTracerPath(obj,fig,varargin)
    
    import internal.stats.parseArgs
    
    % Parse inputs
    optionName          = {'MovingMeanDuration','MarkerInterval','UseENU'}; %   valid options (Name)
    optionDefaultValue  = {seconds(5),minutes(10),true}; %   default value (Value)
    [movingMeanDuration,...
     markerInterval,...
     useENU...
    ]	= parseArgs(optionName,optionDefaultValue,varargin{:}); %   parse function arguments
    
    % Define anonymous functions
    makeVectorComplex   = @(vec) complex(vec(:,1),vec(:,2));
    getAngle            = @(vecA,vecB) rad2deg(real(log((vecB./vecA).*(abs(vecA)./abs(vecB)))./1i));

    nObj    = numel(obj);
    
    hfig    = figure(fig);
    set(hfig,...
        'Visible',      'on');
    clf
    
    spnx                        = 5;
    spny                        = nObj;
    spi                         = reshape(1:spnx*spny,spnx,spny)';
    
    hsp     = gobjects(spnx*spny,1);
    % Create axes
    for col = 1:spnx
        for row = 1:spny
            if col == 5
                pax     = polaraxes;
                hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),pax,...
                                    'NextPlot',                 'add',...
                                    'Layer',                    'top',...
                                    'Box',                      'off',...
                                    'TitleFontWeight',          'normal',...
                                    'TickDir',                  'in',...
                                    'FontSize',                 12,...
                                    'ThetaZeroLocation',        'top',...
                                    'ThetaDir',                 'clockwise');
            else
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
    end
    
    XLimits = NaN(1,2);
    YLimits = NaN(1,2);
    RLimits = NaN(1,2);
    VLimits = zeros(1,2);
    dRLimits = zeros(1,2);
    dirLimits = NaN(1,2);
    hcb = gobjects(spny,1);
    for row = 1:spny
        oo = row;
        
        % TODO: Convert to Himmelsrichtungen
        
        TData       = datetime(obj(oo).TimeDS,'ConvertFrom','datenum');
        if useENU
            VData    = reshape(obj(oo).VelocityRSenu(:,:,1:2),[],2);
        else
            VData    = reshape(obj(oo).VelocityRS(:,:,1:2),[],2);
%             VData    = obj(oo).VelocityQC(:,1:2);
        end
        VData       = VData(1:obj(oo).NSamplesDS,:); % Remove NaN padding if necessary
        VData       = movmean(VData,seconds(movingMeanDuration)*obj(oo).Frequency,1,'omitnan'); % 5 second moving mean velocity (m/s)
        dist        = makeVectorComplex(VData.*(1/obj(oo).Frequency)); % 5 second moving mean distance in (m)
        direction   = angle(dist); % 5 second moving mean current direction (radians)
        speed       = movmean(abs(makeVectorComplex(VData)),seconds(movingMeanDuration)*obj(oo).Frequency,'omitnan'); % 5 second moving mean velocity (m/s)
        speedWarn   = speed < eval([obj(oo).FlagVelocity.EnumerationClassName,'.LowHorizontalVelocity.Threshold']);
        
        AData   = getAngle(dist(1:end - 1),dist(2:end)); % 5 second moving mean change in angle (deg)
        AData   = movmean(AData,1,'omitnan'); % 5 second moving mean change in angle (deg)
        XData   = cumsum(real(dist),'omitnan'); % 5 second moving mean x-position (m)
        YData   = cumsum(imag(dist),'omitnan'); % 5 second moving mean y-position (m)

        % Number of cumulative full rotations
        RData   = cumsum(AData,'omitnan')./360; % 5 second moving mean rotation (# full rotations)
        dRData  = diff(RData).*obj(oo).Frequency; % 5 second moving mean rotation rate (rpm)
        rotWarn = cat(1,abs(dRData) > eval([obj(oo).FlagVelocity.EnumerationClassName,'.HighCurrentRotationRate.Threshold']),false(2,1));

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
                'Marker',               '.',...
                'MarkerEdgeColor',      'none',...
                'MarkerFaceColor',      'flat');
            scatter(hax,XData(rotWarn),YData(rotWarn),[],[0 0 1],...
                'Marker',               'o',...
                'MarkerEdgeColor',      'flat',...
                'MarkerFaceColor',      'none');

            text(hax,XData(ind),YData(ind),cellstr(datestr(TData(ind),'HH:MM:SS')),...
                'Color',                0.8.*ones(1,3),...
                'VerticalAlignment',    'middle',...
                'Clipping',             'on');
            
            hcb(row) = colorbar(hax);
            hcb(row).Label.String = 'rotation rate (rpm)';

            title(hax,obj(oo).Parent.gearId,'Interpreter','none')
            if useENU
                xlabel(hax,'E (m)')
                ylabel(hax,'N (m)')
            else
                xlabel(hax,'X (m)')
                ylabel(hax,'Y (m)')
            end
            
            set(hax,...
                'DataAspectRatio',          ones(1,3))
        
        col = 2;
        hax = hsp(spi(row,col));
            scatter(hax,TData(~speedWarn(1:end - 1) | ~rotWarn(1:end - 1)),RData(~speedWarn(1:end - 1) | ~rotWarn(1:end - 1)),'.k')
            scatter(hax,TData(speedWarn(1:end - 1)),RData(speedWarn(1:end - 1)),'.r');
            scatter(hax,TData(rotWarn(1:end - 1)),RData(rotWarn(1:end - 1)),'ob');
            
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
        
        col = 4;
        hax = hsp(spi(row,col));
            scatter(hax,TData(~rotWarn(1:end - 2)),dRData(~rotWarn(1:end - 2)),'.k')
            scatter(hax,TData(rotWarn(1:end - 2)),dRData(rotWarn(1:end - 2)),'.b');
            
            dRLimits = [min([dRLimits(1);dRData(:)]),max([dRLimits(2);dRData(:)])];
            
            xlabel(hax,'time')
            ylabel(hax,'rotation rate (rpm)')
            
        col = 5;
       	hax = hsp(spi(row,col));
            hph = polarhistogram(hax,direction,36,...
                'DisplayStyle',         'Stair',...
                'Normalization',        'probability');
%             polarscatter(hax,AData,speed(1:end - 1),'.k')
            
            dirLimits = [min([dirLimits(1);reshape(hph.BinCounts./sum(hph.BinCounts),[],1)]),max([dirLimits(2);reshape(hph.BinCounts./sum(hph.BinCounts),[],1)])];
    end
    
    set(hsp(spi(1:spny,1)),...
        'XLim',     XLimits,...
        'YLim',     YLimits,...
        'CLim',     RLimits)
    set(hsp(spi(1:spny,2)),...
        'YLim',     RLimits)
    set(hcb,...
        'Limits',  	RLimits)
    set(hsp(spi(1:spny,3)),...
        'YLim',     VLimits)
    set(hsp(spi(1:spny,4)),...
        'YLim',     dRLimits)
    set(hsp(spi(1:spny,5)),...
        'RLim',     dirLimits)
    
    iilnk = 1;
    hlnk(iilnk) = linkprop(hsp(spi(1:spny,1)),{'XLim','YLim','CLim'});
    iilnk = iilnk + 1;
    hlnk(iilnk) = linkprop(hcb,{'Limits'});
    iilnk = iilnk + 1;
    hlnk(iilnk) = linkprop(hsp(spi(1:spny,2)),{'YLim'});
    iilnk = iilnk + 1;
    hlnk(iilnk) = linkprop(hsp(spi(1:spny,3)),{'YLim'});
    iilnk = iilnk + 1;
    hlnk(iilnk) = linkprop(hsp(spi(1:spny,4)),{'YLim'});
    iilnk = iilnk + 1;
    hlnk(iilnk) = linkprop(hsp(spi(1:spny,5)),{'RLim'});
    iilnk = iilnk + 1;
    for row = 1:spny
        hlnk(iilnk) = linkprop(hsp(spi(row,2:4)),{'XLim'});
        iilnk = iilnk + 1;
    end
    
    hfig.UserData = hlnk;
    
    if nargout == 1
        varargout{1} = hfig;
    end
end