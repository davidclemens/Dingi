function checkForAbsoluteLimits(obj)

    % All limits are defined in the AnalysisKit.Metadata.eddyFluxAnalysis.DataFlag
    % or AnalysisKit.Metadata.eddyFluxAnalysis.DatasetFlag enumeration classes.

    % Check horizontal velocity components limits        
    flagHorizontal    	= abs(obj.VelocityDS(:,1:2)) >= eval([obj.FlagVelocity.EnumerationClassName,'.AbsoluteHorizontalVelocityLimitExceeded.Threshold']);
    obj.FlagVelocity    = obj.FlagVelocity.setFlag('AbsoluteHorizontalVelocityLimitExceeded',1,find(flagHorizontal(:,1)),1);
    obj.FlagVelocity    = obj.FlagVelocity.setFlag('AbsoluteHorizontalVelocityLimitExceeded',1,find(flagHorizontal(:,2)),2);

    % Check vertical velocity limits
    flagVertical      	= abs(obj.VelocityDS(:,3)) >= eval([obj.FlagVelocity.EnumerationClassName,'.AbsoluteVerticalVelocityLimitExceeded.Threshold']);
    obj.FlagVelocity 	= obj.FlagVelocity.setFlag('AbsoluteVerticalVelocityLimitExceeded',1,find(flagVertical),3);

    % Also set the dataset flag, if too many flags were raised.
    flag   	= cat(2,flagHorizontal,flagVertical);
    N       = sum(flag)/numel(flag);
    if N <= eval([obj.FlagDataset.EnumerationClassName,'.AbsoluteLimitsThresholdExceeded.Threshold'])
        obj.FlagDataset = obj.FlagDataset.setFlag('MissingDataThresholdExceeded',0,1,1);
    else
        obj.FlagDataset = obj.FlagDataset.setFlag('MissingDataThresholdExceeded',1,1,1);
    end

    obj.replaceData('AbsoluteHorizontalVelocityLimitExceeded')
    obj.replaceData('AbsoluteVerticalVelocityLimitExceeded')
end