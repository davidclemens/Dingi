function t = readProtocolFile(filename,version,controlUnit)
% READPROTOCOLFILE
    
    import DataKit.importTableFile
    
    pathRessources  = getToolboxRessources('GearKit');
    
    % read raw text first
    rawText     = fileread(filename);
    
    % remove empty lines
    endOfLine   = '\r\n';
    rawText  	= regexprep(rawText,['(',endOfLine,'){2,}'],endOfLine);
    rawText  	= regexprep(rawText,[endOfLine,'$'],'');
    
    % read data
    formatSpec  = '%{MM-dd-yyyy}D%{HH:mm:ss}D%s';
    raw         = textscan(rawText,formatSpec,...
                    'Delimiter',        '\t',...
                    'EndOfLine',        endOfLine);
                
	rawData     = table(raw{:},...
                    'VariableNames',    {'Date','Time','Event'});
	tmpTime         = [datevec(rawData{:,'Date'}),datevec(rawData{:,'Time'})];
    rawData.Time  	= datetime(tmpTime(:,[1,2,3,10,11,12]));
    rawData.Date    = [];
    
    % load ressource table
    bigoEventRE	= importTableFile([pathRessources '/_BIGO_data_RE.xlsx']);
  	% get appropriate event dictionary version
    if ismember(version,bigoEventRE.Version)
        EventDict   = bigoEventRE(bigoEventRE.Version == version,:);  % extract relevant regular expression dictionary
    else
        error('GearKit:bigoDeployment:readProtocolFile:unknownDataVersion',...
            'The data version ''%s'' is unknown.',version);
    end

    % get unique possible tokens
    tmp       	= regexp(bigoEventRE.Tokens,',','split');
    uTok        = {};
    for ii = 1:size(tmp,1)
        uTok    = [uTok;unique(tmp{ii}(:))];   % list of possible named tokens
    end
    uTok(cellfun(@isempty,uTok)) = [];
    uTok        = unique(uTok);
    nuTok       = numel(uTok);


    % –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    % MATCH REGULAR EXPRESSIONS
    % –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
    % initialize
    MatchTable              = rawData;             % initialize MatchTable
    MatchTable.EventMatch   = cell(size(MatchTable,1),2);
    MatchTable              = [MatchTable,cell2table(repmat({NaN(1,2)},[size(rawData,1),nuTok]),'VariableNames',uTok)];

    for row = 1:size(rawData,1) % loop over BIGO protocol rows
        % MATCH ROW WITH Event DICTIONARY
        match   	= cell(size(EventDict,1),2);                            % initialize
        matchtoken 	= cell(size(EventDict,1),2);                            % initialize
        token      	= EventDict{:,{'TokensStart','TokensEnd'}};  % list of expected tokens
        [match(:,1),matchtoken(:,1)]	= regexp(MatchTable.Event(row),EventDict.REStart,'start','names');   % scan for start event
        [match(:,2),matchtoken(:,2)]	= regexp(MatchTable.Event(row),EventDict.REEnd,'start','names');     % scan for end event
        % convert to logical
        match(cellfun(@isempty,match))	= {0};                              % set empty cells to 0
        match                           = cell2mat(match) == 1;             % only keep matches starting at character 1
        % extract expected tokens
        matchtoken(~token)              = {{}};                             % only keep tokens that are expected
        matchtokenmask                  = ~cellfun(@isempty,matchtoken);    % true if token was captured

        % POPULATE MATCH TABLE
        % process matches
        if any(match(:,1)) % if any start RE was matched
            MatchTable{row,'EventMatch'}(:,1)	= {EventDict.EventId(match(:,1))};
        end
        if any(match(:,2)) % if any end RE was matched
            MatchTable{row,'EventMatch'}(:,2)	= {EventDict.EventId(match(:,2))};
        end
        % process matched tokens
        if any(matchtokenmask(:,1)) % if any start token was captured
            startmt     = matchtoken{matchtokenmask(:,1),1};
            startmtfn   = fieldnames(startmt);
            [~,TokInd]  = ismember(startmtfn,uTok);
            for fld = 1:numel(startmtfn) % loop over fieldnames
                MatchTable{row,uTok{TokInd(fld)}}(:,1) = str2double(startmt.(startmtfn{fld}));
            end
        end
        if any(matchtokenmask(:,2)) % if any start token was captured
            endmt     = matchtoken{matchtokenmask(:,2),2};
            endmtfn   = fieldnames(endmt);
            [~,TokInd]  = ismember(endmtfn,uTok);
            for fld = 1:numel(endmtfn) % loop over fieldnames
                MatchTable{row,uTok{TokInd(fld)}}(:,2) = str2double(endmt.(endmtfn{fld}));
            end
        end
    end

    % POSTPROCESS MATCH TABLE
    % remove rows that did not match
    maskNoMatch     = all(cellfun(@isempty,MatchTable.EventMatch),2);
    if sum(maskNoMatch) > 0
        warning('GearKit:bigoDeployment:readProtocolFile:unmatchedEvents',...
            'There were %g unmatched events in the following protocol file:\n\t%s\n',sum(maskNoMatch),filename);
    end
    
    MatchTable(maskNoMatch,:) = [];
    % deal with rows that match multiple events
    MultiMatchMask    = sum(cellfun(@numel,MatchTable.EventMatch),2)./size(MatchTable.EventMatch,2) > 1;
    MultiMatchMask    = find(MultiMatchMask);
    for ii = 1:numel(MultiMatchMask) % loop over rows with multiple matches
        mstart  = MatchTable{MultiMatchMask(ii),'EventMatch'}{1};  % extract start event ID
        mend    = MatchTable{MultiMatchMask(ii),'EventMatch'}{2}; 	% extract end event ID
        if all(mstart == mend) % check if all start and end event IDs are the same
            for ss = 1:numel(mstart) % loop over all matches
                MatchTable(end + 1,:)             	= MatchTable(MultiMatchMask(ii),:);                  	% append copy of row to end of MatchTable
                MatchTable{end,'EventMatch'}{1}    = MatchTable{MultiMatchMask(ii),'EventMatch'}{1}(ss);  % alter the start entry to the current one
                MatchTable{end,'EventMatch'}{2}    = MatchTable{MultiMatchMask(ii),'EventMatch'}{2}(ss);  % alter the end entry to the current one
            end     
        end
    end
    MatchTable(MultiMatchMask,:)                                            = [];                               % remove double entries
    MatchTable{:,'EventMatch'}(cellfun(@isempty,MatchTable.EventMatch))   = {NaN};                            % replace empty entries with NaN
    MatchTable.EventMatch                                                  = cell2mat(MatchTable.EventMatch); % convert to double
    % sort MatchTable
    MatchTable  = sortrows(MatchTable,{'Time'});


    % initialize
    MatchTable.MTRowNo	= (1:size(MatchTable,1))';  % add column with row number to MatchTable
    t                   = table([],[],[],...
                            'VariableNames',    {'EventId','RowStart','RowEnd'});

    % CHECK CHRONOLOGY OF EVENTS
    % initialize lists for open and closing events
    EventOpen           = table([],[],[],...
                            'VariableNames',    {'EventId','RowStart','RowEnd'});
    EventClose          = table([],...
                            'VariableNames',    {'EventId'});
    for row = 1:size(MatchTable,1)  % loop over rows of this control unit
        if ~isnan(MatchTable{row,'EventMatch'}(1)) % if event opens
            EventOpen           = [EventOpen;{MatchTable{row,'EventMatch'}(1),MatchTable{row,'MTRowNo'},NaN}];
        end
        if ~isnan(MatchTable{row,'EventMatch'}(2)) % if event closes
            EventClose          = [EventClose;{MatchTable{row,'EventMatch'}(2)}];
        end
        [ECinEO,ECinEOind]  = ismember(EventClose.EventId,EventOpen.EventId);   % find closing events in open events list
        if sum(ECinEO) > 0 % if an open event is closed
            EventOpen.RowEnd(ECinEOind)	= MatchTable{row,'MTRowNo'};       	% assign row number of closed event
            t                    = [t;EventOpen(ECinEOind,:)]; 	% assign closed events to BIGOtime
            EventOpen(ECinEOind,:)      = [];                                   % remove closed events from open events list
            EventClose(ECinEO,:)        = [];                                   % remove closed events from close events list
        end
    end

    % ERROR HANDLING
    EventOpenN  = size(EventOpen,1); % number of open events remaining in list
    if EventOpenN > 0 % if open events remain in list
        % post warnings
        for ev = 1:EventOpenN
            ErrorEvent(ev,1)   = EventDict.Event(EventDict.EventId == EventOpen.EventId(ev));
        end
        warning('\nOne or more events for\n\t%s\nhave no end time:\n\t%s\n',filename,strjoin(cellstr(ErrorEvent),'\n\t'))

        % #####################################################
        % # TO-TO: deal with cases, where end time is missing #
        % #####################################################
        %BIGOtime                    = [BIGOtime;EventOpen(:,:)]; 	% assign closed events to BIGOtime
    end
    

    % POSTPROCESS BIGOtime TABLE
    % assign several values from match table to BIGOtime    % get ControlUnit ID
    t.Subgear             	= cell(size(t,1),1);                     % initialize Subgear column
    t{:,'MeasuringDeviceType'} 	= GearKit.measuringDeviceType.undefined;                     % initialize MeasuringDevice column
    t.SampleId             	= cell(size(t,1),1);                     % initialize SampleId column

    t.StartTime           	= MatchTable.Time(t.RowStart);       % get event StartTime
    t.EndTime              	= MatchTable.Time(t.RowEnd);         % get event EndTime
    [~,imInd]              	= ismember(t.EventId,EventDict.EventId);
    t.Event               	= EventDict.Event(imInd); % match event name from event dictionary
    uTokExtended           	= [uTok;{'Nis'}];                               % add Nis to non-system events
    [MaskToken,IndToken]   	= ismember(t.Event,uTokExtended);        % find rows with tokens
 	t.Subgear(~MaskToken) 	= cellstr(controlUnit); % write ControlUnit number to Subgear for system events
    t.SampleId(MaskToken)  	= uTokExtended(IndToken(MaskToken));            % write token to SampleId for non-system events
    t.SampleId(~MaskToken) 	= {'System'};                                   % set SampleId of system events
    t.Subgear(MaskToken) 	= {''};                                         % set Subgear of non-system events

    % calculations
    t.Time           = t.StartTime + 0.5*(t.EndTime - t.StartTime);	% calculate DateTime
    t.Duration       = hours(t.EndTime - t.StartTime);                     % calculate duration
    % assign captured tokens from MatchTable as columns to BIGOtime
    for tok = 1:nuTok % loop over tokens
        t{:,end + 1}                     = NaN(size(t,1),2);                      % initialize Variable
        t.Properties.VariableNames{end}  = uTok{tok};                             % assign Variable name
        t{:,uTok{tok}}(:,1)              = MatchTable{t.RowStart,uTok{tok}}(:,1); % add token start value
        t{:,uTok{tok}}(:,2)              = MatchTable{t.RowEnd,uTok{tok}}(:,2);   % add token end value
    end
    
    
    % compute token meanings
    ExtraCapRows 	= table();
    
    
    maskSyr     = t.Event == 'Syr';
    maskSyrExt  = t.Event == 'SyrExt';
    maskSyrRes  = t.Event == 'SyrRes';
    maskCap     = t.Event == 'Cap';
    maskInj     = t.Event == 'Inj';
    indNis      = find(t.Event == 'Nis');
    nSyr        = sum(maskSyr);
    nSyrExt     = sum(maskSyrExt);
    nSyrRes     = sum(maskSyrRes);
    nCap        = sum(maskCap);
    nInj        = sum(maskInj);
    nNis        = numel(indNis);
    
    % define measuringDevice
    t{maskSyr | maskSyrExt | maskSyrRes,'MeasuringDeviceType'}  = GearKit.measuringDeviceType.BigoSyringeSampler;
    t{maskCap,'MeasuringDeviceType'}                            = GearKit.measuringDeviceType.BigoCapillarySampler;
    t{maskInj,'MeasuringDeviceType'}                            = GearKit.measuringDeviceType.BigoInjector;
    t{indNis,'MeasuringDeviceType'}                             = GearKit.measuringDeviceType.BigoNiskinBottle;
    
    % switch on the version of regular expression table
    switch version
        case 'v1'
            % process internal syringes
            t.Subgear(maskSyr)     	= cellstr(t.ControlUnit(maskSyr,1));
            t.SampleId(maskSyr)    	= strcat({'Syr'},num2str(t.Syr(maskSyr,1),'%02d'));
            % process external syringes
            t.Subgear(maskSyrExt) 	= {'BW'};
            t.SampleId(maskSyrExt) 	= strcat({'Syr'},num2str(t.SyrExt(maskSyrExt,1),'%02d'));
            % process reservoir syringes
            t.Subgear(MaskSyrRes)  	= strcat(cellstr(t.ControlUnit(MaskSyrRes,1)),{'Res'});
            t.SampleId(MaskSyrRes) 	= strcat({'Syr'},num2str(t.SyrRes(MaskSyrRes,1),'%02d'));
            % process niskin
            t.Subgear(indNis(1)) 	= {'Niskin'};
            t.SampleId(indNis(1)) 	= {'Niskin01'};
            if nNis > 1
                t(indNis(2:end),:) 	= [];           % delete Nis for 2nd control unit
            end
        case {'v2','v3'}
            % process internal syringes
            t.Subgear(maskSyr)   	= cellstr(t.ControlUnit(maskSyr,1));
            t.SampleId(maskSyr)  	= strcat({'Syr'},num2str(t.Syr(maskSyr,1),'%02d'));
            % process external syringes
            t.Subgear(maskSyrExt)	= {'BW'};
            t.SampleId(maskSyrExt)  = strcat({'Syr'},num2str(t.SyrExt(maskSyrExt,1),'%02d'));
            % process capillary sampler
            t.Subgear(maskCap)   	= {'BW'};
            [~,CapInd]            	= sort(t.DateTime(maskCap));
            t.SampleId(maskCap)   	= strcat({'Cap'},num2str(CapInd,'%02d'));
            ExtraCapRows                       = repmat(t(maskCap,:),2,1);
            ExtraCapRows.Subgear(1:nCap)       = {'Ch1'};
            ExtraCapRows.Subgear(nCap + 1:end) = {'Ch2'};
            t                     	= [t;ExtraCapRows];
            % process niskin
            t.Subgear(indNis(1)) 	= {'Niskin'};
            t.SampleId(indNis(1))	= {'Niskin01'};
            if nNis > 1
                t(indNis(2:end),:)	= [];           % delete Nis for 2nd control unit
            end
        case {'v4','v5'}
            % process internal syringes
            t.Subgear(maskSyr)  	= {controlUnit};
            t.SampleId(maskSyr)   	= strcat({'Syr'},num2str(t.Syr(maskSyr,1),'%02d'));
            % process external syringes
            t.Subgear(maskSyrExt)	= {'BW'};
            t.SampleId(maskSyrExt)	= strcat({'Syr'},num2str(t.SyrExt(maskSyrExt,1),'%02d'));
            % process capillary sampler
            t.Subgear(maskCap)     	= {'BW'};
            t.SampleId(maskCap)   	= strcat({'Cap'},num2str(t.Cap(maskCap,1),'%02d'));
            ExtraCapRows                       = repmat(t(maskCap,:),2,1);
            ExtraCapRows.Subgear(1:nCap)       = {'Ch1'};
            ExtraCapRows.Subgear(nCap + 1:end) = {'Ch2'};
            % process niskin
            if nNis > 0
                t.Subgear(indNis(1)) 	= {'Niskin'};
                t.SampleId(indNis(1)) 	= {'Niskin01'};
            end
            if nNis > 1
                t(indNis(2:end),:)	= [];           % delete Nis for 2nd control unit
            end
            % process injections
            if nInj > 0
                t.Subgear(maskInj)   	= {controlUnit};
                [~,InjInd]           	= sort(t.Time(maskInj));
                t.SampleId(maskInj)  	= strcat({'Inj'},num2str(InjInd,'%02d'));
                % #####################################################
                % # TO-TO: Extract Subgear from Experiment file       #
                % #####################################################

%                 maskBIGOexpInd	= find(BIGOexp{:,'Cruise'}   == uCr{cr} & ...
%                                        BIGOexp{:,'Gear'}     == uG{g});
%                 IsInjInd	= find(~isnan(BIGOexp{maskBIGOexpInd,'InjID'}));
%                 nn          = numel(IsInjInd);
%                 t{maskInj,'Subgear'}     = cellstr(BIGOexp{maskBIGOexpInd(IsInjInd(1)),'Subgear'});
%                 if nn > 1
%                     for ii = 2:nn
%                         tmpTable                = t(maskInj,:);
%                         tmpTable{:,'Subgear'} 	= cellstr(BIGOexp{maskBIGOexpInd(IsInjInd(ii)),'Subgear'});
%                     end
%                     tAppend    = [tAppend;tmpTable];
%                 end
            end
    end
            
    % append additional injection events
   	t             	= [t;ExtraCapRows];
    t             	= sortrows(t,{'Subgear','SampleId','Time'});    % sort BIGOtime
    
    
    t.Subgear   	= categorical(t.Subgear);
    t.SampleId      = categorical(t.SampleId);

end