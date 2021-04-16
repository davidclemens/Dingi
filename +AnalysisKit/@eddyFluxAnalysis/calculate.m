function varargout = calculate(obj,varargin)
% CALCULATE

    import internal.stats.parseArgs
    import AnalysisKit.eddyFluxAnalysis.downsample

    nargoutchk(0,1)

    % parse Name-Value pairs
    optionName          = {'Downsample','RotateCoordinateSystem','DetrendFluxParameter','DetrendVerticalVelocity','TimeShift','CalculateCospectrum'}; % valid options (Name)
    optionDefaultValue  = {false,false,false,false,false,false}; % default value (Value)
    [doDownsample,...
     rotateCoordinateSystem,...
     detrendFluxParameter,...
     detrendVerticalVelocity,...
     doTimeShift,...
     doCalculateCospectrum...
    ]	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments




    % TODO: despiking


    % subsample
    if doDownsample
        obj.TimeDownsampled          = downsample(obj.TimeRaw,obj.Downsamples);
        obj.VelocityDownsampled      = downsample(obj.VelocityRaw,obj.Downsamples);
        obj.FluxParameterDownsampled = downsample(obj.FluxParameterRaw,obj.Downsamples);
    end

    % calculate coordinate system rotation
    if rotateCoordinateSystem
        [i,j,k] = csUnitVectors(obj);
        obj.CoordinateSystemUnitVectorI = i;
        obj.CoordinateSystemUnitVectorJ = j;
        obj.CoordinateSystemUnitVectorK = k;
    end

    % detrending of vertical velocity
    if detrendVerticalVelocity
        obj.detrend(...
            'DetrendFluxParameter',     false,...
            'DetrendVerticalVelocity',  true);
    end

    % detrending of flux parameter(s)
    if detrendFluxParameter
        obj.detrend(...
            'DetrendFluxParameter',     true,...
            'DetrendVerticalVelocity',  false);
    end

    % Time shift signals
    if doTimeShift
        obj.timeShift
    end

    if doCalculateCospectrum
        obj.calculateCospectrum
    end

    if nargout == 1
        varargout{1} = obj;
    end
end
