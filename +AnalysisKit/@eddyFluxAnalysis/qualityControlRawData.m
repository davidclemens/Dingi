function varargout = qualityControlRawData(obj)

    import DebuggerKit.Debugger.printDebugMessage
    
    nargoutchk(0,1)
   
    printDebugMessage('Verbose','Checking for missing data ...')
    checkForMissingData(obj)
    
    printDebugMessage('Verbose','Checking against absolute limits ...')
    checkForAbsoluteLimits(obj)
    
    printDebugMessage('Verbose','Checking for spikes ...')
    checkForSpikes(obj)
    
    printDebugMessage('Verbose','Checking for current obstructions ...')
    checkForCurrentObstructions(obj)
    
    printDebugMessage('Verbose','Checking amplitude resolution ...')
    % checkForAmplitudeResolution(obj)
    
    printDebugMessage('Verbose','Checking for dropouts ...')
    % checkForDropouts(obj)
    
    printDebugMessage('Verbose','Checking the signal to noise ratio ...')
    checkForSignalToNoiseRatio(obj)
    
    printDebugMessage('Verbose','Checking the beam correlation ...')
    checkForBeamCorrelation(obj)
    
    printDebugMessage('Verbose','Checking for low horizontal velocities ...')
    checkForLowHorizontalVelocity(obj)
    
    printDebugMessage('Verbose','Checking for high horizontal current rotation rates ...')
    checkForHighCurrentRotation(obj)
    
    if nargout == 1
        varargout{1} = obj;
    end
end