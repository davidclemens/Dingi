function runAnalysis(obj,varargin)
% RUNANALYSIS
                      
    import internal.stats.parseArgs
    import AnalysisKit.eddyFluxAnalysis

    % parse Name-Value pairs
    optionName          = {'Start','End'}; % valid options (Name)
    optionDefaultValue  = {[],[]}; % default value (Value)
    [startTime,...
     endTime...
     ]	= parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments

    
    nObj    = numel(obj);
    for oo = 1:nObj
        
%         data     = obj(oo).data.fetchData({'velocityU','velocityV','velocityW','oxygen'},[],[],'NortekVector');

        % Get time & velocity data
%         [dp1,var1]  	= obj(oo).data.findVariable('Variable',{'Time','VelocityU','VelocityV','VelocityW'},'VariableMeasuringDevice.Type','NortekVector');
        dp1     = obj(oo).data.findVariable('Variable','Oxygen','VariableMeasuringDevice.Type','PyrosciencePico');
        dp      = unique(dp1);
        
        [time,velocity,snr,bc,fluxParameter] = extractRelevantData(obj(oo).data,dp);
        
        maskTime        = time >= datenum(obj(oo).timeOfInterestStart) & ...
                          time <= datenum(obj(oo).timeOfInterestEnd);

     	obj(oo).analysis	= eddyFluxAnalysis(time(maskTime,:),velocity(maskTime,:),fluxParameter(maskTime,:),...
            'SNR',              snr(maskTime,:),...
            'BeamCorrelation',  bc(maskTime,:),...
            'Start',            startTime,...
            'End',              endTime,...
            'ObstacleAngles',   [0,120,180,240]);
    end
    
    function [t,v,snr,bc,fp] = extractRelevantData(dataPool,poolIdx)
        
        info            = dataPool.Index(ismember(dataPool.Index{:,'DataPool'},poolIdx),:);
        
        t   	= [];
        v   	= [];
        snr     = [];
        bc   	= [];
        fp      = [];
        for ii = 1:numel(poolIdx)
            maskInfo    = ismember(info{:,'DataPool'},poolIdx(ii));
            
            timeInd             = info{:,'Variable'} == 'Time';
            [~,varInd]          = ismember(info{maskInfo,'Variable'},{'VelocityU','VelocityV','VelocityW','Oxygen','SignalToNoiseRatio1','SignalToNoiseRatio2','SignalToNoiseRatio3','BeamCorrelation1','BeamCorrelation2','BeamCorrelation3'});
            
            [D,F]	= dataPool.fetchVariableData(info{maskInfo & timeInd,'DataPool'},info{maskInfo & timeInd,'VariableIndex'});
            
            F       = ~F{1}.isFlag('MarkedRejected');
            
            t  	= cat(1,t,datenum(D{1}(F)));
            v  	= cat(1,v,dataPool.Data{poolIdx(ii)}(F,ismember(varInd,1:3)));
            fp	= cat(1,fp,dataPool.Data{poolIdx(ii)}(F,ismember(varInd,4)));
            snr = cat(1,snr,dataPool.Data{poolIdx(ii)}(F,ismember(varInd,5:7)));
            bc  = cat(1,bc,dataPool.Data{poolIdx(ii)}(F,ismember(varInd,8:10)));
        end
    end
end
