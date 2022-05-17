function checkForBeamCorrelation(obj)

    % Check beam correlation (BC)
    flag                = obj.BeamCorrelationDS < eval([obj.FlagVelocity.EnumerationClassName,'.LowBeamCorrelation.Threshold']);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowBeamCorrelation',1,find(flag(:,1)),1);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowBeamCorrelation',1,find(flag(:,2)),2);
    obj.FlagVelocity  	= obj.FlagVelocity.setFlag('LowBeamCorrelation',1,find(flag(:,3)),3);

    % Also set the dataset flag, if too many flags were raised.
    N       = sum(flag)/numel(flag);
    if N <= eval([obj.FlagDataset.EnumerationClassName,'.LowBeamCorrelation.Threshold'])
        obj.FlagDataset = obj.FlagDataset.setFlag('LowBeamCorrelation',0,1,1);
    else
        obj.FlagDataset = obj.FlagDataset.setFlag('LowBeamCorrelation',1,1,1);
    end

    obj.replaceData('LowBeamCorrelation')
end