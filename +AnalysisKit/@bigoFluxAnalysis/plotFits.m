function varargout = plotFits(obj,variable,axesProperties)

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
    for col = 1:spnx
        oo = col;
        for row = 1:spny
            var = row;
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),axesProperties{:});
                maskFitsInd	= find(obj(oo).FitVariables == variable(var));
                nFits       = numel(maskFitsInd);
                if isempty(maskFitsInd)
                    text(0.5,0.5,'no data','Units','normalized')
                    return
                end
                deviceDomains   = obj(oo).FitDeviceDomains(maskFitsInd);

                yFitData    = NaN(n,nFits);
                for ff = 1:nFits
                    dp      = obj(oo).PoolIndex(maskFitsInd(ff));
                    var     = obj(oo).VariableIndex(maskFitsInd(ff));
                    data    = fetchData(obj(oo).Bigo.data,[],[],[],[],dp,var,...
                                'ForceCellOutput',  false);

                    xData  	= obj(oo).TimeUnitFunction(data.IndepData{:} - obj(oo).FitOriginTime(maskFitsInd(ff)));
                    yData   = data.DepData;
                    exclude	= isFlag(data.Flags,'ExcludeFromFit');

                    % Extract limits
                    xLimits(spi(row,col),:) = [nanmin([xLimits(spi(row,col),1);xData(~exclude)]), nanmax([xLimits(spi(row,col),2);xData(~exclude)])];
                    yLimits(spi(row,col),:) = [nanmin([yLimits(spi(row,col),1);yData(~exclude)]), nanmax([yLimits(spi(row,col),2);yData(~exclude)])];
                    
                    if sum(~exclude) > 20
                        marker = '.';
                    else
                        marker = 'o';
                    end
                    scatter(xData(exclude),yData(exclude),...
                        'Marker',           '+',...
                        'MarkerEdgeColor',  0.8.*ones(1,3))
                    scatter(xData(~exclude),yData(~exclude),...
                        'Marker',           marker,...
                        'MarkerEdgeColor',  hsp(spi(row,col)).ColorOrder(ff,:))

                    xFitData        = obj(oo).TimeUnitFunction(linspace(obj(oo).FitStartTime(ff),obj(oo).FitEndTime(ff),n))';
                    yFitData(:,ff)  = feval(obj(oo).FitObjects{maskFitsInd(ff)},xFitData);
                end
                hp(spi(row,col),1:nFits) = plot(xFitData,yFitData);
                set(hp(spi(row,col),1:nFits),...
                    {'Color'},    num2cell(hsp(spi(row,col)).ColorOrder(1:nFits,:),2))

                legendLabels = strcat({deviceDomains.Abbreviation}');
                legend(hp(spi(row,col),1:nFits),legendLabels)
                
                yLabelString{row}   = data.DepInfo.Variable.Abbreviation;
        end
     	xLabelString{col}   = data.IndepInfo.Variable{1}.Abbreviation;
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
        {'String'},     yLabelString)
        
end