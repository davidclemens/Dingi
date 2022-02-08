function varargout = runCoordinateSystemRotation(obj)

    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)
    
    nObj    = numel(obj);
    
    for oo = 1:nObj
        printDebugMessage('Info','Rotating coordinate system for %s ...',obj(oo).Parent.gearId)
        
        % Set update flag to updating
        stackDepth  = 4;
        obj(oo).UpdateStack(stackDepth) = 1;
    
        rotateCoordinateSystem(obj(oo))
        printDebugMessage('Info','Rotating coordinate system for %s ... done',obj(oo).Parent.gearId)
        
        printDebugMessage('Info','Segregating averaging intervals for %s ...',obj(oo).Parent.gearId)
        rotateSegregateScalars(obj(oo))
        printDebugMessage('Info','Segregating averaging intervals for %s ... done',obj(oo).Parent.gearId)

        % Set update flag to updated
        obj(oo).UpdateStack(stackDepth) = 0;
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end