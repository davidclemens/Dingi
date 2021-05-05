function varargout = runQualityControl(obj)

    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)
    
    printDebugMessage('Info','Quality controlling raw data ...')
    
    printDebugMessage('Info','Finding and replacing bad data ...')
    obj.qualityControlRawData
    printDebugMessage('Info','Finding and replacing bad data ... done')
    
    printDebugMessage('Info','Quality controlling raw data ... done')
    
    if nargout == 1
        varargout{1} = obj;
    end
end