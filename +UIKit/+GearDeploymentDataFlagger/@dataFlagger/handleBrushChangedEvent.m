function handleBrushChangedEvent(src,~)

    % Extract handles
    df  = src.UserData.dataFlagger;
    br  = df.DataBrush;
    
    if br.BrushDataChanged
        
        % Set status text
        setStatusText(df,'Applying selection ...')

        % Retrieve indices and brush data
        poolIdx         = cat(1,br.Charts{:,'userData'}{:});
        variableIdx     = poolIdx(:,2);
        poolIdx         = poolIdx(:,1);
        brushData       = cellfun(@find,br.Charts{:,'brushData'},'un',0);
        nData           = cellfun(@numel,br.Charts{:,'brushData'});
        nBrushedData    = cellfun(@numel,brushData);

        % Grow vectors to match data
        poolIdxAll      = arrayfun(@(n,p) p.*ones(n,1),nData,poolIdx,'un',0);
        poolIdxAll      = cat(1,poolIdxAll{:});
        variableIdxAll	= arrayfun(@(n,v) v.*ones(n,1),nData,variableIdx,'un',0);
        variableIdxAll	= cat(1,variableIdxAll{:});
        sampleIdxAll    = arrayfun(@(n) (1:n)',nData,'un',0);
        sampleIdxAll    = cat(1,sampleIdxAll{:});
        
        % Grow vectors to match brush data
        poolIdxBrushed      = arrayfun(@(n,p) p.*ones(n,1),nBrushedData,poolIdx,'un',0);
        poolIdxBrushed      = cat(1,poolIdxBrushed{:});
        variableIdxBrushed	= arrayfun(@(n,v) v.*ones(n,1),nBrushedData,variableIdx,'un',0);
        variableIdxBrushed	= cat(1,variableIdxBrushed{:});
        sampleIdxBrushed   	= reshape(cat(2,brushData{:}),[],1);
        
        % Apply flags
        df.applyFlags(poolIdxAll,sampleIdxAll,variableIdxAll,poolIdxBrushed,sampleIdxBrushed,variableIdxBrushed);

        % Set status text
        setStatusText(df,'')
    end
end