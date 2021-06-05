function checkForAmplitudeResolution(obj)

    dataSetNames    = {'Velocity','FluxParameter'};

    for ds = 1:numel(dataSetNames)
        checkAmplitudeResolutionForDataset(obj,dataSetNames{ds});
    end
    function flag = checkAmplitudeResolutionForDataset(obj,dataSetName)

        dataSetNameRaw  = [dataSetName,'DS'];
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