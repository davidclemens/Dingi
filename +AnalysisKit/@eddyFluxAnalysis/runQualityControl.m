function varargout = runQualityControl(obj)

    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)
    
    nObj    = numel(obj);
    
    for oo = 1:nObj
    
        printDebugMessage('Info','Quality controlling raw data for %s ...',obj(oo).Parent.gearId)
        
        % Set update flag to updating
        stackDepth  = 3;
        obj(oo).UpdateStack(stackDepth) = 1;
        
        obj(oo).TimeQC          = obj(oo).TimeDS;
        obj(oo).VelocityQC    	= obj(oo).VelocityDS;
        obj(oo).FluxParameterQC	= obj(oo).FluxParameterDS;

        obj(oo).qualityControlRawData

        printDebugMessage('Info','Quality controlling raw data for %s ... done',obj(oo).Parent.gearId)

        % Set update flag to updated
        obj(oo).UpdateStack(stackDepth) = 0;
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end