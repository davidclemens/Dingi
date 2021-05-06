function varargout = runQualityControl(obj)

    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)
    
    printDebugMessage('Info','Quality controlling raw data ...')
    
    % Set update flag to updating
    obj.UpdateQC = 'IsUpdating';
    
    printDebugMessage('Info','Finding and replacing bad data ...')
    obj.qualityControlRawData
    printDebugMessage('Info','Finding and replacing bad data ... done')
    
    printDebugMessage('Info','Quality controlling raw data ... done')
    
    % Set update flag to updated
    obj.UpdateQC = 'IsUpdated';
    
    if nargout == 1
        varargout{1} = obj;
    end
end