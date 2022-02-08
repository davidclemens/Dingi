function varargout = checkUpdateStack(obj,stackDepth)

    nargoutchk(0,1)
    
    updating        = any(obj.UpdateStack(1:stackDepth) == 1);
    if updating
%         warning('A dependency is currently updating.')
        return
    end
    
    updateRequired	= any(obj.UpdateStack(1:stackDepth) == 2);
    
    while updateRequired
        updateIndex = find(obj.UpdateStack(1:stackDepth) == 2,1);
        switch updateIndex
            case 1
            case 2
                obj.runDownsampling
            case 3
                obj.runQualityControl
            case 4
                obj.runCoordinateSystemRotation
            case 5
        end
        updateRequired	= any(obj.UpdateStack(1:stackDepth) == 2);
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end