function varargout = qualityControlRawData(obj)

    import DebuggerKit.Debugger.printDebugMessage
    
    nargoutchk(0,1)
   
    printDebugMessage('Verbose','Checking for missing data ...')
    checkMissingData(obj)
    
    printDebugMessage('Verbose','Checking against absolute limits ...')
    checkAbsoluteLimits(obj)
    
    printDebugMessage('Verbose','Checking for current obstructions ...')
    checkCurrentDirection(obj)
    
    printDebugMessage('Verbose','Checking amplitude resolution ...')
%     checkAmplitudeResolution(obj)
    
    printDebugMessage('Verbose','Checking for dropouts ...')
    checkForDropouts(obj)
    
    printDebugMessage('Verbose','Checking the signal to noise ratio ...')
    checkSignalToNoiseRatio(obj)
    
    printDebugMessage('Verbose','Checking the beam correlation ...')
    checkBeamCorrelation(obj)
    
    if nargout == 1
        varargout{1} = obj;
    end
    
    function checkMissingData(obj)
        
        % % missing/deleted     flag
        %   	N <= 3%         0
        %       N >  3%         1
        
        nMissing    = sum(isnan(obj.TimeRaw(:))) + sum(isnan(obj.VelocityRaw(:))) + sum(isnan(obj.FluxParameterRaw(:)));
        nTotal      = numel(obj.TimeRaw) + numel(obj.VelocityRaw) + numel(obj.FluxParameterRaw);
        
        N   = nMissing/nTotal;
        
        if N <= eval([obj.FlagDataset.EnumerationClassName,'.MissingDataThresholdExceeded.Threshold'])
            obj.FlagDataset = obj.FlagDataset.setFlag('MissingDataThresholdExceeded',0,1,1);
        else
            obj.FlagDataset = obj.FlagDataset.setFlag('MissingDataThresholdExceeded',1,1,1);
        end
    end
    function checkAbsoluteLimits(obj)
        
        % All limits are defined in the AnalysisKit.Metadata.eddyFluxAnalysis.DataFlag
        % or AnalysisKit.Metadata.eddyFluxAnalysis.DatasetFlag enumeration classes.
        
        % Check horizontal velocity components limits        
        flagHorizontal    	= abs(obj.VelocityRaw(:,1:2)) >= eval([obj.FlagVelocity.EnumerationClassName,'.AbsoluteHorizontalVelocityLimitExceeded.Threshold']);
        obj.FlagVelocity    = obj.FlagVelocity.setFlag('AbsoluteHorizontalVelocityLimitExceeded',1,find(flagHorizontal(:,1)),1);
        obj.FlagVelocity    = obj.FlagVelocity.setFlag('AbsoluteHorizontalVelocityLimitExceeded',1,find(flagHorizontal(:,2)),2);
        
        % Check vertical velocity limits
        flagVertical      	= abs(obj.VelocityRaw(:,3)) >= eval([obj.FlagVelocity.EnumerationClassName,'.AbsoluteVerticalVelocityLimitExceeded.Threshold']);
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
    function checkCurrentDirection(obj)
        
        import DataKit.bitmask
        
        % Convert the horizontal velocity components (u,v) to a complex
        % number:
        direction	= complex(obj.VelocityRaw(:,1),obj.VelocityRaw(:,2));
        
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
        
        N   = numel(flag)/size(obj.VelocityRaw,1);
        
        % If too many data points have bad absolute limits, also set the
        % dataset flag.        
        if N <= eval([obj.FlagDataset.EnumerationClassName,'.ObstructedCurrentDirectionThresholdExceeded.Threshold'])
            obj.FlagDataset = obj.FlagDataset.setFlag('ObstructedCurrentDirectionThresholdExceeded',0,1,1);
        else
            obj.FlagDataset = obj.FlagDataset.setFlag('ObstructedCurrentDirectionThresholdExceeded',1,1,1);
        end
    end
    function checkAmplitudeResolution(obj)
        
        dataSetNames    = {'Velocity','FluxParameter'};
        
        for ds = 1:numel(dataSetNames)
            checkAmplitudeResolutionForDataset(obj,dataSetNames{ds});
        end
        function flag = checkAmplitudeResolutionForDataset(obj,dataSetName)
        
            dataSetNameRaw  = [dataSetName,'Raw'];
            dataSetNameFlag = ['Flag',dataSetName];
            windowSize      = 1000;
            windowOverlap   = windowSize/2;
            nBins           = 100;

            data            = obj.(dataSetNameRaw);
            

            [nData,nSeries]	= size(data);
            
            nWindows        = ceil((nData - windowSize + 1)/windowOverlap);
            
            xEmptyBins  = NaN(nWindows,1);
            flag        = false(nData,nSeries);
            for win = 1:nWindows
                % Get data start and end
                s = windowOverlap*(win - 1) + 1;
                e = s + windowSize - 1;
                
                xEmptyBins(win) = floor(mean([s,e]));
                for ser = 1:nSeries
                    % Get the actual data
                    d = data(s:e,ser);
                    
                    % Get the total bin range
                    binRange    = min([7*std(d),range(d)]);
                    
                    % Get the bin limits centering the bin range around the
                    % data mean
                    binLimits 	= mean(d) + 0.5.*[-1 1].*binRange;
                    
                    % Get the bin edges
                    binEdges    = linspace(binLimits(1),binLimits(2),nBins + 1);
                    
                    % Compute the bin counts and tally up the empty bins
                    nEmptyBins  = sum(histcounts(d,binEdges) == 0);
                    
                    % Set a flag for the entire window if the threshold is
                    % exceeded
                    flag(s:e,ser) = flag(s:e,ser) | nEmptyBins/nBins > eval([obj.(dataSetNameFlag).EnumerationClassName,'.LowAmplitudeResolution.Threshold']);
                end
            end
            [i,j] = find(flag);
            obj.(dataSetNameFlag)	= obj.(dataSetNameFlag).setFlag('LowAmplitudeResolution',1,i,j);
        end        
    end
    function checkForDropouts(obj)
    end
    function checkSignalToNoiseRatio(obj)
        
        % Check signal to noise ratio (SNR)
        flag                = obj.SNR < eval([obj.FlagVelocity.EnumerationClassName,'.LowSignalToNoiseRatio.Threshold']);
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
    end
    function checkBeamCorrelation(obj)
        
        % Check beam correlation (BC)
        flag                = obj.BeamCorrelation < eval([obj.FlagVelocity.EnumerationClassName,'.LowBeamCorrelation.Threshold']);
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
    end
end