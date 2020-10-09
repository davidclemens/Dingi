function envelope = calculateAxesEnvelope(obj)
    
        
    binIndex = discretize(obj.CommonAxesData(:,2),obj.CommonAxesEnvelopeBinCount);
    
    % exclude NaNs
    binMask  = ~isnan(binIndex);
    
    % bin, axes, min/max
    envelopeDu	= cat(3,...
                    accumarray([binIndex(binMask),obj.CommonAxesData(binMask,1)],obj.IndividualAxesData(binMask,2),[],@nanmin,NaN),...
                    accumarray([binIndex(binMask),obj.CommonAxesData(binMask,1)],obj.IndividualAxesData(binMask,2),[],@nanmax,NaN));
                
    
    switch obj.CommonAxis
        case 'XAxis'
            envelope        = dataUnits2Centimeters(envelopeDu,obj.IndividualAxesDataLimits',obj.AxesPositionCurrent(:,4)');
            envelope(:,:,2)	= obj.AxesPositionCurrent(:,4)' - envelope(:,:,2);
        case 'YAxis'
            envelope        = dataUnits2Centimeters(envelopeDu,obj.IndividualAxesDataLimits',obj.AxesPositionCurrent(:,3)');
            envelope(:,:,2)	= obj.AxesPositionCurrent(:,3)' - envelope(:,:,2);
    end

    % handle reversed axes
    isReverse                   = find(strcmp(obj.IndividualAxesDirection,'reverse'));
    envelope(:,isReverse,[1 2]) = envelope(:,isReverse,[2 1]);
end