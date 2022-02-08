function varargout = runDetrending(obj)

    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)
    
    nObj    = numel(obj);
    
    for oo = 1:nObj
        printDebugMessage('Info','Detrending for %s ...',obj(oo).Parent.gearId)
        
        % Set update flag to updating
        stackDepth  = 5;
        obj(oo).UpdateStack(stackDepth) = 1;
    
        detrend(obj(oo))
        printDebugMessage('Info','Detrending for %s ... done',obj(oo).Parent.gearId)

        % Set update flag to updated
        obj(oo).UpdateStack(stackDepth) = 0;
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end