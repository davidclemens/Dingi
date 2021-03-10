function setFlagForAllVariablesOfMeasurementdevice(obj)

    % Extract relevant handles
    br = obj.DataBrush;
    df = br.Figure.UserData.dataFlagger;
    
    % Set status text
    setStatusText(df,'Applying to measuring device  ...')
    
    % The current axis is the one that the context menu has been invoked
    % from.
    hax = gca;
    
    % Extract the relevant charts
    axisIndex   = br.nAxes - find(ismember({br.Axes.Tag}',hax.Tag)) + 1;
    charts      = br.Charts(br.Charts.indAxis == axisIndex,:);
    
    % Retrieve indices and brush data
    poolIdx         = cat(1,charts{:,'userData'}{:});
    poolIdx         = poolIdx(:,1);
    brushData       = cellfun(@find,charts{:,'brushData'},'un',0);
    nBrushedData    = cellfun(@numel,brushData);
    
    % Get size of relevant data pools
    nDataPools = size(charts,1);
    nS = NaN(nDataPools,1);
    nV = NaN(nDataPools,1);
    for md = 1:nDataPools
        [nS(md),nV(md)] = size(df.Deployments(df.DeploymentIsSelected).data.Data{poolIdx(md)});
    end
    
 	% Grow vectors to match data
    poolIdxAll      = arrayfun(@(ns,nv,p) reshape(p.*ones(ns,nv),[],1),nS,nV,poolIdx,'un',0);
    poolIdxAll      = cat(1,poolIdxAll{:});
    variableIdxAll	= arrayfun(@(ns,nv) reshape((1:nv).*ones(ns,1),[],1),nS,nV,'un',0);
    variableIdxAll	= cat(1,variableIdxAll{:});
    sampleIdxAll    = arrayfun(@(ns,nv) reshape(repmat((1:ns)',1,nv),[],1),nS,nV,'un',0);
    sampleIdxAll    = cat(1,sampleIdxAll{:});
    
    % Grow vectors to match brush data
    poolIdxBrushed      = arrayfun(@(ns,nv,p) reshape(p.*ones(ns,nv),[],1),nBrushedData,nV,poolIdx,'un',0);
    poolIdxBrushed      = cat(1,poolIdxBrushed{:});
    variableIdxBrushed	= arrayfun(@(ns,nv) reshape((1:nv).*ones(ns,1),[],1),nBrushedData,nV,'un',0);
    variableIdxBrushed	= cat(1,variableIdxBrushed{:});
    sampleIdxBrushed   	= cellfun(@(nv,b) reshape(repmat(reshape(b,[],1),1,nv),[],1),num2cell(nV),brushData,'un',0);
    sampleIdxBrushed	= cat(1,sampleIdxBrushed{:});
    
    % Apply flags
    df.applyFlags(poolIdxAll,sampleIdxAll,variableIdxAll,poolIdxBrushed,sampleIdxBrushed,variableIdxBrushed);

    % Set status text
    setStatusText(df,'')
end
