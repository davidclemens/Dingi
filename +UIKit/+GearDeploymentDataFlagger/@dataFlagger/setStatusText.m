function setStatusText(obj,str)

    hStatus         = findall(obj.FigureHandle,'Tag','HeaderStatusText');
    hStatus.String  = str;
    drawnow nocallbacks
end