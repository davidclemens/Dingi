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
        dpRapid1	= obj(oo).data.findVariable('Variable','Oxygen','VariableMeasuringDevice.Type','PyrosciencePico');
        dpRapid     = unique(dpRapid1);
        
        dpSlow1     = obj(oo).data.findVariable('Variable','Pitch');
        dpSlow      = unique(dpSlow1);
        
        [timeRapid,timeSlow,velocity,snr,bc,fluxParameter,pitchRollHeading] = extractRelevantData(obj(oo).data,dpRapid,dpSlow);
        
        maskTimeRapid	= timeRapid >= datenum(obj(oo).timeOfInterestStart) & ...
                          timeRapid <= datenum(obj(oo).timeOfInterestEnd);
        maskTimeSlow	= timeSlow >= datenum(obj(oo).timeOfInterestStart) & ...
                          timeSlow <= datenum(obj(oo).timeOfInterestEnd);

     	obj(oo).analysis	= eddyFluxAnalysis(timeRapid(maskTimeRapid,:),velocity(maskTimeRapid,:),fluxParameter(maskTimeRapid,:),...
            'SNR',              snr(maskTimeRapid,:),...
            'BeamCorrelation',  bc(maskTimeRapid,:),...
            'Start',            startTime,...
            'End',              endTime,...
            'ObstacleAngles',   [0,120,180,240],...
            'PitchRollHeading',	mean(pitchRollHeading(maskTimeSlow,:)),...
            'Parent',           obj(oo));
    end
    
    function [tRapid,tSlow,v,snr,bc,fp,prh] = extractRelevantData(dataPool,poolIdxRapid,poolIdxSlow)
        
        infoRapid	= dataPool.Index(ismember(dataPool.Index{:,'DataPool'},poolIdxRapid),:);
        infoSlow	= dataPool.Index(ismember(dataPool.Index{:,'DataPool'},poolIdxSlow),:);
        
        tRapid  = [];
        v   	= [];
        snr     = [];
        bc   	= [];
        fp      = [];
        for ii = 1:numel(poolIdxRapid)
            maskInfo    = ismember(infoRapid{:,'DataPool'},poolIdxRapid(ii));
            
            timeInd             = infoRapid{:,'Variable'} == 'Time';
            [~,varInd]          = ismember(infoRapid{maskInfo,'Variable'},{'VelocityU','VelocityV','VelocityW','Oxygen','SignalToNoiseRatio1','SignalToNoiseRatio2','SignalToNoiseRatio3','BeamCorrelation1','BeamCorrelation2','BeamCorrelation3'});
            
            [D,F]	= dataPool.fetchVariableData(infoRapid{maskInfo & timeInd,'DataPool'},infoRapid{maskInfo & timeInd,'VariableIndex'});
            
            F       = ~F{1}.isFlag('MarkedRejected');
            
            tRapid	= cat(1,tRapid,datenum(D{1}(F)));
            v       = cat(1,v,dataPool.Data{poolIdxRapid(ii)}(F,ismember(varInd,1:3)));
            fp      = cat(1,fp,dataPool.Data{poolIdxRapid(ii)}(F,ismember(varInd,4)));
            snr     = cat(1,snr,dataPool.Data{poolIdxRapid(ii)}(F,ismember(varInd,5:7)));
            bc      = cat(1,bc,dataPool.Data{poolIdxRapid(ii)}(F,ismember(varInd,8:10)));
        end
        
        tSlow	= [];
        prh     = [];
        for ii = 1:numel(poolIdxSlow)
            maskInfo    = ismember(infoSlow{:,'DataPool'},poolIdxSlow(ii));
            
            timeInd             = infoSlow{:,'Variable'} == 'Time';
            [~,varInd]          = ismember(infoSlow{maskInfo,'Variable'},{'Pitch','Roll','Heading'});
            
            [D,F]	= dataPool.fetchVariableData(infoSlow{maskInfo & timeInd,'DataPool'},infoSlow{maskInfo & timeInd,'VariableIndex'});
            
            F       = ~F{1}.isFlag('MarkedRejected');
            
            tSlow	= cat(1,tSlow,datenum(D{1}(F)));
            prh     = cat(1,prh,dataPool.Data{poolIdxSlow(ii)}(F,ismember(varInd,1:3)));
        end
    end
end
