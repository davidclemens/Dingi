function obj = linkCommonAxes(obj)

    if obj.NAxes > 0
        props   = {[obj.CommonAxis(1),'Lim'],...
                   [obj.CommonAxis(1),'Dir']};
        obj.CommonAxesLink = linkprop(obj.Children,props);
    end
end