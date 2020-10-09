function callbackFigureSizeChanged(obj,src,~)
    
    src.Visible          = 'off';
    drawNow(obj);
    src.Visible          = 'on';
end