function checkForCurrentObstructions(obj)

    import DataKit.bitmask

    % Convert the horizontal velocity components (u,v) to a complex
    % number:
    direction	= complex(obj.VelocityDS(:,1),obj.VelocityDS(:,2));

    % Calculate the absolute horizontal velocity
    velocity    = movmean(abs(direction),2*obj.Frequency);

    % Calculate the angle using the phase angle of the complex numbers
    % and transform it to be in decimal degrees in the interval
    % (0,360).
    alpha       = movmean(mod(rad2deg(angle(direction)),360),2*obj.Frequency);

    % Generate angle interval limits from the provided obstacle angles.
    % First expand the obstacle angles to also include each angle with
    % an additional rotation. This solves issues with obstacles close
    % to 0/360 degrees.
    alphaLimits = reshape([0 360] + obj.ObstacleAngles,1,[]);

    % Now create the interval limits by adding and substracting half of
    % the obstacle sector width. Shift these limits to the 3rd array
    % dimension
    alphaLimits = alphaLimits + shiftdim([-0.5 0.5].*obj.ObstacleSectorWidth,-1);

    % Now check all limits at once, utilizing MATLABs implicit array
    % expanpsion. Only flag directions with a significant water velocity.
    flag = find(velocity >= 0.01 & ...
                any(alpha < alphaLimits(:,:,2) & alpha > alphaLimits(:,:,1),2));

    % Set data flag
    obj.FlagVelocity	= obj.FlagVelocity.setFlag('ObstructedCurrentDirection',1,flag,1);
    obj.FlagVelocity	= obj.FlagVelocity.setFlag('ObstructedCurrentDirection',1,flag,2);
    obj.FlagVelocity	= obj.FlagVelocity.setFlag('ObstructedCurrentDirection',1,flag,3);

    N   = numel(flag)/size(obj.VelocityDS,1);

    % If too many data points have bad absolute limits, also set the
    % dataset flag.        
    if N <= eval([obj.FlagDataset.EnumerationClassName,'.ObstructedCurrentDirectionThresholdExceeded.Threshold'])
        obj.FlagDataset = obj.FlagDataset.setFlag('ObstructedCurrentDirectionThresholdExceeded',0,1,1);
    else
        obj.FlagDataset = obj.FlagDataset.setFlag('ObstructedCurrentDirectionThresholdExceeded',1,1,1);
    end
end