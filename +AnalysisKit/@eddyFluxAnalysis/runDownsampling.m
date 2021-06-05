function varargout = runDownsampling(obj)

    import AnalysisKit.eddyFluxAnalysis.downsample
    import DebuggerKit.Debugger.printDebugMessage

    nargoutchk(0,1)
    
    nObj    = numel(obj);
    
    for oo = 1:nObj
        printDebugMessage('Info','Downsampling raw data for %s ...',obj(oo).Parent.gearId)
        
        % Set update flag to updating
        obj(oo).UpdateDownsamples = 'IsUpdating';

        obj(oo).TimeDS              = downsample(obj(oo).TimeRaw,obj(oo).Downsamples);
        obj(oo).VelocityDS          = downsample(obj(oo).VelocityRaw,obj(oo).Downsamples);
        obj(oo).FluxParameterDS     = downsample(obj(oo).FluxParameterRaw,obj(oo).Downsamples);
        obj(oo).SNRDS               = downsample(obj(oo).SNR,obj(oo).Downsamples);
        obj(oo).BeamCorrelationDS   = downsample(obj(oo).BeamCorrelation,obj(oo).Downsamples);

        printDebugMessage('Info','Downsampling raw data for %s ... done',obj(oo).Parent.gearId)

        % Set update flag to updated
        obj(oo).UpdateDownsamples = 'IsUpdated';
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
end