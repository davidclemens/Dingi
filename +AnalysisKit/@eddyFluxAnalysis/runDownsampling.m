function varargout = runDownsampling(obj)

    import AnalysisKit.eddyFluxAnalysis.downsample
    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)
    
    printDebugMessage('Info','Downsampling raw data ...')
    
    % Set update flag to updating
    obj.UpdateDownsamples = 'IsUpdating';
    
    obj.TimeDS_             = downsample(obj.TimeRaw,obj.Downsamples);
    obj.VelocityDS_         = downsample(obj.VelocityRaw,obj.Downsamples);
    obj.FluxParameterDS_    = downsample(obj.FluxParameterRaw,obj.Downsamples);
    obj.SNRDS               = downsample(obj.SNR,obj.Downsamples);
    obj.BeamCorrelationDS   = downsample(obj.BeamCorrelation,obj.Downsamples);
    
    printDebugMessage('Info','Downsampling raw data ... done')
    
    % Set update flag to updated
    obj.UpdateDownsamples = 'IsUpdated';
    
    if nargout == 1
        varargout{1} = obj;
    end
end