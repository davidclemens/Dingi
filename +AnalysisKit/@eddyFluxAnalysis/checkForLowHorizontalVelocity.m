function checkForLowHorizontalVelocity(obj)

    makeVectorComplex = @(vec) complex(vec(:,1),vec(:,2));

    % Check horizontal velocity magnitude
    VData       = movmean(obj.VelocityQC(:,1:2),5*obj.Frequency,1,'omitnan'); % 5 second moving mean velocity (m/s)
    speed       = movmean(abs(makeVectorComplex(obj.VelocityQC(:,1:2))),15*60*obj.Frequency,'omitnan'); % 15 minute moving mean velocity (m/s)
    speedFlag   = find(speed < eval([obj.FlagVelocity.EnumerationClassName,'.LowHorizontalVelocity.Threshold']));

    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowHorizontalVelocity',1,speedFlag,1);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowHorizontalVelocity',1,speedFlag,2);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowHorizontalVelocity',1,speedFlag,3);

    % Also set the dataset flag, if too many flags were raised.    
    N       = numel(speedFlag)/size(VData,1);
    if N <= eval([obj.FlagDataset.EnumerationClassName,'.LowHorizontalVelocity.Threshold'])
        obj.FlagDataset = obj.FlagDataset.setFlag('LowHorizontalVelocity',0,1,1);
    else
        obj.FlagDataset = obj.FlagDataset.setFlag('LowHorizontalVelocity',1,1,1);
    end
end