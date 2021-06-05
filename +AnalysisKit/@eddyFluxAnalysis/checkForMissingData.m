function checkForMissingData(obj)

    % % missing/deleted     flag
    %   	N <= 3%         0
    %       N >  3%         1

    nMissing    = sum(isnan(obj.TimeRaw(:))) + sum(isnan(obj.VelocityRaw(:))) + sum(isnan(obj.FluxParameterRaw(:)));
    nTotal      = numel(obj.TimeDS) + numel(obj.VelocityDS) + numel(obj.FluxParameterDS);

    N   = nMissing/nTotal;

    if N <= eval([obj.FlagDataset.EnumerationClassName,'.MissingDataThresholdExceeded.Threshold'])
        obj.FlagDataset = obj.FlagDataset.setFlag('MissingDataThresholdExceeded',0,1,1);
    else
        obj.FlagDataset = obj.FlagDataset.setFlag('MissingDataThresholdExceeded',1,1,1);
    end
end