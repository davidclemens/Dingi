function checkForHighCurrentRotation(obj)

    makeVectorComplex   = @(vec) complex(vec(:,1),vec(:,2));
    getAngle            = @(vecA,vecB) rad2deg(real(log((vecB./vecA).*(abs(vecA)./abs(vecB)))./1i));
    
    % Check high horizontal velocity rotation rate
    VData   = movmean(obj.VelocityQC(:,1:2),5*obj.Frequency,1,'omitnan'); % 5 second moving mean velocity (m/s)
    dist  	= makeVectorComplex(VData.*(1/obj.Frequency)); % 5 second moving mean distance in (m)
    AData   = getAngle(dist(1:end - 1),dist(2:end)); % 5 second moving mean change in angle (deg)
    AData   = movmean(AData,5*60/5,'omitnan'); % 5 minute moving mean change in angle (deg)

    % Number of cumulative full rotations
    RData   = cumsum(AData,'omitnan')./360; % 5 minute moving mean rotation (# full rotations)
    dRData  = diff(RData).*obj.Frequency*60; % 5 minute moving mean rotation rate (rpm)
    rotFlag = find(cat(1,abs(dRData) > eval([obj.FlagVelocity.EnumerationClassName,'.HighCurrentRotationRate.Threshold']),false(2,1)));

    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('HighCurrentRotationRate',1,rotFlag,1);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('HighCurrentRotationRate',1,rotFlag,2);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('HighCurrentRotationRate',1,rotFlag,3);

    % Also set the dataset flag, if too many flags were raised.
    N       = numel(rotFlag)/size(VData,1);
    if N <= eval([obj.FlagDataset.EnumerationClassName,'.HighCurrentRotationRate.Threshold'])
        obj.FlagDataset = obj.FlagDataset.setFlag('HighCurrentRotationRate',0,1,1);
    else
        obj.FlagDataset = obj.FlagDataset.setFlag('HighCurrentRotationRate',1,1,1);
    end
end