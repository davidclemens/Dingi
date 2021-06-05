function varargout = despikePST(obj,datasetName)
% CALCULATE
    
    import AnalysisKit.eddyFluxAnalysis.plotPhaseSpace
    
    nargoutchk(0,1)
    
    data                = obj.([datasetName,'DS']);
    [nData,nSeries]     = size(data);
    
    % (-1) remove mean
    dataMean            = mean(data);
    dataMeanRemoved     = timeseries(data - dataMean,obj.TimeDS);
    

    % (0) remove long period fluctuations
    highPassFrequency   = 1/60^2; % Hz
    dataHighPassed      = idealfilter(dataMeanRemoved,[highPassFrequency Inf],'pass');
    dataHighNotched     = idealfilter(dataMeanRemoved,[highPassFrequency Inf],'notch'); % Has to be added again in the end

 	flag                = false(nData,nSeries);
    dataDespiked        = NaN(nData,nSeries);
    for ser = 1:nSeries % loop over data series
        Data            = dataHighPassed.Data(:,ser);
        mask            = true(nData,3);
        run             = true;
        iter            = 1;
        while run
            fprintf('Dimension %d of %d: Despiking iteration %d ... ',ser,nSeries,iter)

            % (1) get first and second derivative
            dData               = derive(Data);
            d2Data              = derive(dData);

            % (2) get standard deviations and the expected maxima using the 
            %     Universal criterion
            sigma       = [std(Data,'omitnan'),...
                           std(dData,'omitnan'),...
                           std(d2Data,'omitnan')];
            uniCrit  	= universalCriterion(Data,sigma);

            % (3) Calculate the rotation angle of the principal axis of 
            %     d2Data versus Data using the cross correlation
            theta       = [0,atan(sum(Data.*d2Data,'omitnan')./sum(Data.^2,'omitnan')),0];
            
%             plotPhaseSpace(Data,dData,d2Data,uniCrit,theta)

            % (4) Calculate ellipses for the pairs data-dData,
            %     dData-d2Data & dData-d2Data
            %     x-y:      1-2,    1-3,    2-3
            %     major:    1,      1,      2
            %     minor:    2,      3,      3           
            maskNew     = [getOutlierMask(theta(1),Data,dData,uniCrit(1),uniCrit(2)),...
                           getOutlierMask(theta(2),Data,d2Data,uniCrit(1),uniCrit(3)),...
                           getOutlierMask(theta(3),dData,d2Data,uniCrit(2),uniCrit(3))];
            maskChanged = sum(reshape(maskNew ~= mask,[],1)) > 0;
            mask        = maskNew;

            % (5) replace spikes
            Data(any(mask,2))               = NaN;
            Data                            = fillmissing(Data,obj.ReplaceMethod);
            flag(any(mask,2),ser)           = true;


            nDespiked   = sum(mask(:));
            run         = nDespiked ~= 0 && ...
                          maskChanged && ...
                          iter <= 10;
            iter = iter + 1;

            fprintf('%d spikes replaced\n',nDespiked)
        end
        dataDespiked(:,ser)     = Data;
        
        % Set data flag
        obj.(['Flag',datasetName])	= obj.(['Flag',datasetName]).setFlag('Spike',1,find(flag(:,ser)),ser);
    end
    % Set data
%     obj.([datasetName,'QC'])	= dataDespiked + dataHighNotched.Data + dataMean;

    
    N   = sum(flag(:))/numel(obj.([datasetName,'QC']));

    % If too many data points have spikes, also set the dataset flag.        
    if N <= eval([obj.FlagDataset.EnumerationClassName,'.SpikeThresholdExceeded.Threshold'])
        obj.FlagDataset = obj.FlagDataset.setFlag('SpikeThresholdExceeded',0,1,1);
    else
        obj.FlagDataset = obj.FlagDataset.setFlag('SpikeThresholdExceeded',1,1,1);
    end
    
    if nargout == 1
        varargout{1} = obj;
    end
    
    function dy = derive(x)
        dy      = [NaN;...
                   0.5.*(x(3:end) - x(1:end - 2));...
                   NaN];
    end
    function uniCrit = universalCriterion(data,sigma)
        uniCrit = sqrt(2.*log(size(data,1))).*sigma;
    end
    function mask = getOutlierMask(theta,x,y,a,b)
        mask	= (cos(theta).*x + sin(theta).*y).^2./a.^2 + ...
                  (sin(theta).*x - cos(theta).*y).^2./b.^2 > 1;
        % TODO do this (^) as a matrix multiplication
    end
end