function y = dataUnits2Centimeters(x,dataLimits,lengthLimits)

    dataRange   = range(dataLimits);
    
    scale       = lengthLimits./dataRange;   % cm/du
    
    y           = (x - dataLimits(1,:)).*scale;
end