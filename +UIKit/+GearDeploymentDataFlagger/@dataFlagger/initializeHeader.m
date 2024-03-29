function initializeHeader(obj)

    % Determine header canvas position
    obj.HeaderCanvas    = [...
        obj.OuterMargin,...
        obj.FigurePosition(4) - obj.FigureSafeZoneHeight - obj.OuterMargin - obj.HeaderHeight,...
        obj.FigurePosition(3) - 2*obj.OuterMargin - obj.PanelOptionsWidth - obj.InnerMargin,...
        obj.HeaderHeight];
    
    
    hHeaderTitle = uicontrol(obj.FigureHandle,...
        'Style',                'text',...
        'Tag',                  'HeaderTitleText',...
        'String',               'Data Flagger',...
        'Units',                obj.Units,...
        'Position',             obj.HeaderCanvas.*[1 1 0.5 1],...
        'FontName',             obj.FontName,...
        'FontSize',             obj.FontSize*obj.FontSizeTitleMultiplier,...
        'HorizontalAlignment',  'left');
    
    hHeaderStatus = uicontrol(obj.FigureHandle,...
        'Style',                'text',...
        'Tag',                  'HeaderStatusText',...
        'String',               'Loading ...',...
        'Units',                obj.Units,...
        'Position',             obj.HeaderCanvas.*[1 1 0.5 1] + [0.5.*obj.HeaderCanvas(3),0,0,0],...
        'FontName',             obj.FontName,...
        'FontSize',             obj.FontSize,...
        'HorizontalAlignment',  'right');
end