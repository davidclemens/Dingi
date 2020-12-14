function charts = getBrushData(obj)
% GETBRUSHDATA

    charts          = table();
    nCharts         = arrayfun(@(a) numel(a.Children),obj.Axes);
    
    % since the last graphics object/axis drawn is added to the top layer,
    % the indexing is reversed.
    chartIndexAxis	= arrayfun(@(n,i) repmat(i,n,1),nCharts,(obj.nAxes:-1:1)','un',0);
    chartIndexChild	= arrayfun(@(n) (n:-1:1)',nCharts,'un',0);
    
    chartIndexAxis  = cat(1,chartIndexAxis{:});
    chartIndexChild = cat(1,chartIndexChild{:});
    
    charts.indAxis  = chartIndexAxis;
    charts.indChild = chartIndexChild;
    charts.chart    = cat(1,obj.Axes.Children);
    
    charts.tags         = get(charts.chart,{'Tag'});
    charts.userData     = get(charts.chart,{'UserData'});
    charts.brushData    = cellfun(@logical,get(charts.chart,{'BrushData'}),'un',0);
    dataSize            = cellfun(@size,get(charts.chart,{'XData'}),'un',0);
    maskBrushDataEmpty  = cellfun(@isempty,charts.brushData);
    if any(maskBrushDataEmpty)
        charts{maskBrushDataEmpty,'brushData'}  = cellfun(@(s) false(s(1),s(2)),dataSize(maskBrushDataEmpty),'un',0);
    end
    
    charts      = sortrows(charts,{'indAxis','indChild'});
end