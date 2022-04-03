function varargout = plotFluxViolin(obj,variable,axesProperties)

    hsp     = gobjects();
    hv      = gobjects();
    
    nVariables  = numel(variable);
    nObj        = numel(obj);
    
    spnx                        = ceil(sqrt(nVariables));
    spny                        = ceil(nVariables/spnx);
    spi                         = reshape(1:spnx*spny,spnx,spny)';
    
    n = 100;
    xLimits         = NaN(spnx*spny,2);
    yLimits         = NaN(spnx*spny,2);
    yLabelString 	= cell(spny,1);
    xLabelString 	= cell(spnx,1);
    for col = 1:spnx
        for row = 1:spny
            var = spi(row,col);
            if var > nVariables
                continue
            end
            hsp(spi(row,col))   = subplot(spny,spnx,spi(row,col),axesProperties{:});
                    
                flux        = [];
                grouping    = [];
                for oo = 1:nObj
                    maskFitsInd	= obj(oo).FitVariables == variable(var);
                    grouping    = cat(1,grouping,repmat(obj(oo).Parent.areaId,sum(maskFitsInd),1));
                    flux    = cat(1,flux,obj(oo).Fluxes(maskFitsInd,:));
                end
                grouping = repmat(grouping,1,size(flux,2));
                hv(spi(row,col)) = violin(flux(:),grouping(:));

                xLimits(spi(row,col),:) = [min(hv(spi(row,col)).Vertices(:,1)),max(hv(spi(row,col)).Vertices(:,1))];
                yLimits(spi(row,col),:) = [min(hv(spi(row,col)).Vertices(:,2)),max(hv(spi(row,col)).Vertices(:,2))];
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
        {'String'},     yLabelString)
end