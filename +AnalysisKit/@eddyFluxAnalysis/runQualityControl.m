function varargout = runQualityControl(obj)

    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)
    
    nObj    = numel(obj);
    
    for oo = 1:nObj
    
        printDebugMessage('Info','Quality controlling raw data for %s ...',obj(oo).Parent.gearId)

        obj(oo).TimeQC          = obj(oo).TimeDS;
        obj(oo).VelocityQC    	= obj(oo).VelocityDS;
        obj(oo).FluxParameterQC	= obj(oo).FluxParameterDS;

        % Set update flag to updating
        obj(oo).UpdateQC = 'IsUpdating';

        obj(oo).qualityControlRawData

        printDebugMessage('Info','Quality controlling raw data for %s ... done',obj(oo).Parent.gearId)

        % Set update flag to updated
        obj(oo).UpdateQC = 'IsUpdated';
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end