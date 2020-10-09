function obj = initialize(obj)
% INITIALIZE
    
    obj.Parent.Visible          = 'off';
%     obj.Parent.SizeChangedFcn   = '@obj.callbackFigureSizeChanged';
    
%     set(obj.Parent,...
%         'MenuBar',          'none',...
%         'ToolBar',          'none')
    
	obj = getAxesData(obj);
    
 	obj = linkCommonAxes(obj);
    
    obj = initializeAxesAppearance(obj);

    obj.Parent.Visible  = 'on';
    obj.IsInitialized   = true;
end