function varargout = timeShift(obj)

    nargoutchk(0,1)
    
    maxLag  = 60; % in seconds
    
%     figure(13)
%     clf
    
    timeLag     = NaN(obj.FluxParameterN,1);
    for fp = 1:obj.FluxParameterN
        [r,lag] = xcorr(reshape(obj.W_(:,1:obj.WindowN),[],1),reshape(obj.FluxParameter_(:,1:obj.WindowN,fp),[],1),maxLag*obj.Frequency);
        
        [~,maxInd] = max(abs(r));
        
        timeLag(fp) = lag(maxInd);
        
%         plot(lag./obj.Frequency,r)
%         hold on
    end
    
%     xlabel('dt (s)')
%     ylabel('correlation')
    
    
    obj.FluxParameterTimeShift = timeLag;
    

    if nargout == 1
        varargout{1} = obj;
    end
end