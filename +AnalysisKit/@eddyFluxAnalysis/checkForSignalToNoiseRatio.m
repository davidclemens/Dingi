function checkForSignalToNoiseRatio(obj)

    % Check signal to noise ratio (SNR)
    flag                = obj.SNRDS < eval([obj.FlagVelocity.EnumerationClassName,'.LowSignalToNoiseRatio.Threshold']);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowSignalToNoiseRatio',1,find(flag(:,1)),1);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowSignalToNoiseRatio',1,find(flag(:,2)),2);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowSignalToNoiseRatio',1,find(flag(:,3)),3);

    % Also set the dataset flag, if too many flags were raised.
    N       = sum(flag)/numel(flag);
    if N <= eval([obj.FlagDataset.EnumerationClassName,'.LowSignalToNoiseRatio.Threshold'])
        obj.FlagDataset = obj.FlagDataset.setFlag('LowSignalToNoiseRatio',0,1,1);
    else
        obj.FlagDataset = obj.FlagDataset.setFlag('LowSignalToNoiseRatio',1,1,1);
    end

    obj.replaceData('LowSignalToNoiseRatio')
end