function obj = calculate(obj,varargin)
% CALCULATE

    % parse Name-Value pairs
    optionName          = {'Downsample','RotateCoordinateSystem','DetrendFluxParameter','DetrendVerticalVelocity'}; % valid options (Name)
    optionDefaultValue  = {false,false,false,false}; % default value (Value)
    [Downsample,...
     RotateCoordinateSystem,...
     DetrendFluxParameter,...
     DetrendVerticalVelocity,...
    ]	= internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments




    % TODO: despiking
    % subsample
    if Downsample
        obj.timeDownsampled          = downsample(obj.timeRaw,obj.downsamples);
        obj.velocityDownsampled      = downsample(obj.velocityRaw,obj.downsamples);
        obj.fluxParameterDownsampled = downsample(obj.fluxParameterRaw,obj.downsamples);
    end
    
    % calculate coordinate system rotation
    if RotateCoordinateSystem
        [i,j,k] = csUnitVectors(obj);
        obj.coordinateSystemUnitVectorI = i;
        obj.coordinateSystemUnitVectorJ = j;
        obj.coordinateSystemUnitVectorK = k;
    end
    
    % detrending of vertical velocity
    if DetrendVerticalVelocity
        obj = obj.detrend(...
                'DetrendFluxParameter',     false,...
                'DetrendVerticalVelocity',  true);
    end
    
    % detrending of flux parameter(s)
    if DetrendFluxParameter
        obj = obj.detrend(...
                'DetrendFluxParameter',     true,...
                'DetrendVerticalVelocity',  false);
    end
end