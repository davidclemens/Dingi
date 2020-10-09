function ind = createFileIndex(obj,varargin)
% CREATEFILEINDEX Indexes a Nortek instrument object
% Indexes a Nortek instrument object and tests the checksums of all
% all binary data structures. The file index is cached for faster
% performance but can be manually reset.
%
% Syntax
%   ind = CREATEFILEINDEX(NortekInstrumentFile)
%   ind = CREATEFILEINDEX(__,Name,Value)
%
% Description
%   ind = CREATEFILEINDEX(NortekInstrumentFile) indexes the Nortek
%       instrument object and returns the index.
%
%   ind = CREATEFILEINDEX(__,Name,Value) specifies additional parameters 
%       using one or more name-value pair arguments as listed below.
%
%
% Example(s) 
%
%
% Input Arguments
%   obj - an object of class NortekInstrumentFile
%       The Nortek instrument object that should be indexed.
%
%
% Name-Value Pair Arguments
%   Reindex - Reindex instrument file
%       false (default) | true
%           Set to true if the Nortek instrument file should be reindexed.
%
% 
% See also
%
% Copyright 2020 David Clemens (dclemens@geomar.de)

    % parse Name-Value pairs
    optionName          = {'Reindex'}; % valid options (Name)
    optionDefaultValue  = {false}; % default value (Value)
    resetIndexFile      = internal.stats.parseArgs(optionName,optionDefaultValue,varargin{:}); % parse function arguments
    
    %% SETUP
    import ECToolbox.*
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: starting file indexing\n');
    end
    
    % LOAD INDEX FILE
    indexFilename   = [obj.fileInfo.path,'/',obj.fileInfo.name,'.ectind'];
    if 2 == exist(indexFilename,'file') && ...
       ~resetIndexFile
       	if obj.debugger.debugLevel >= 'Info'
            fprintf('INFO: loading cached index from file ...');
        end
        
        load(indexFilename,'-mat','ind');
       	
        if obj.debugger.debugLevel >= 'Info'
            fprintf(' done\n');
            fprintf('INFO: finished file indexing. %d data structures were found.\n      These structure Ids were found: %s.\n',size(ind.OffsetInBytes,1),strjoin(cellstr(num2str(unique(ind.Id))),', '));
        end
        return
    elseif 2 == exist(indexFilename,'file') && ...
           resetIndexFile
        if obj.debugger.debugLevel >= 'Info'
            fprintf('INFO: resetting index file\n');
        end
    end
    
    %% DEFINITIONS
    structMeta          = NortekInstrumentFile.getNortekFileStructureMetadata(); % get table with metadata of Nortek data structure
    syncByte            = 165; % 0xA5
    [~,~,cpuByteOrder]	= computer; % get the byte order of this computer
    nBytes              = size(obj.rawData,1); % get size
    
    %% find sync bytes in the raw data
   	if obj.debugger.debugLevel >= 'Info'
        fprintf('VERBOSE: Finding data structures...\n');
    end
    maskSync            = obj.rawData == syncByte;
    if obj.debugger.debugLevel >= 'Verbose'
        nSyncBytes   	= NaN(5,1);
        nSyncBytes(1)   = sum(maskSync);
        fprintf('VERBOSE: Finding data structures... # sync ids remaining: %d\n',nSyncBytes(1));
    end
    
    %% only keep sync bytes if they are followed by a known id byte
    % find id bytes in the raw data
    maskId              = ismember(obj.rawData, structMeta{:,'Id'});
    maskSync            = [maskSync(1:end - 1) & maskId(2:end); false];
    if obj.debugger.debugLevel >= 'Verbose'
        nSyncBytes(2)   = sum(maskSync);
        fprintf('VERBOSE: Finding data structures... # sync ids remaining: %d (%d)\n',nSyncBytes(2),diff(nSyncBytes(1:2)));
    end
    
    %% only keep sync bytes if the size read in data record (if existant)
    %  is consistent with the expected one (if known) otherwise remove 
    %  those false sync bytes.
    maskNoSizeInDataYetKnown	= ~structMeta{:,'HasSizeInfoInData'} & ...
                                  ~isnan(structMeta{:,'SizeWords'});
    maskSizeKnown              	=  structMeta{:,'HasSizeInfoInData'} & ...
                                  ~isnan(structMeta{:,'SizeWords'});
    
	maskIds             = shiftMask(maskSync,1,1); % get mask for remaining ids (1 byte after sync byte, 1 byte long)
    idsRawData       	= obj.rawData(maskIds); % get the actual ids
	maskSize            = shiftMask(maskSync,2,2); % get mask for size in data (2 bytes after sync byte, 2 bytes long)
    sizeRawData         = bytecast(obj.rawData(maskSize),'L','uint16',cpuByteOrder); % get the actual size in words (1 word = 2 bytes)
    
    % get a mask of id bytes that we know to not have size info in the data
    % record but we know the size anyways
    tmpList             = structMeta(maskNoSizeInDataYetKnown,:);
    [im,imInd]          = ismember(idsRawData,tmpList{:,'Id'});
    sizeRawData(im)     = tmpList{imInd(im),'SizeWords'}; % insert known sizes

    % 
    sizesExpected       = NaN(size(idsRawData)); % if size is not known, set to NaN
    tmpList             = structMeta(maskSizeKnown,:);
    [im,imInd]          = ismember(idsRawData,tmpList{:,'Id'});
    sizesExpected(im)   = tmpList{imInd(im),'SizeWords'};
    
    maskUnkownSize     	= isnan(sizesExpected);
    sizesExpected(maskUnkownSize) = sizeRawData(maskUnkownSize);

    maskSync(maskSync)  = sizeRawData == sizesExpected;
    if obj.debugger.debugLevel >= 'Verbose'
        nSyncBytes(3)   = sum(maskSync);
        fprintf('VERBOSE: Finding data structures... # sync ids remaining: %d (%d)\n',nSyncBytes(3),diff(nSyncBytes(2:3)));
    end
    
    clear sizesExpected;
    

    %% 
    % TODO check if a structure ends after another has started
    
    %%
    % we check that the size read in data record (when exist) is consistent 
    % with the one found between 2 Sync

	maskIds             = shiftMask(maskSync,1,1); % get mask for remaining ids (1 byte after sync byte, 1 byte long)
    idsRawData       	= obj.rawData(maskIds); % get the actual ids
	maskSize            = shiftMask(maskSync,2,2); % get mask for size in data (2 bytes after sync byte, 2 bytes long)
    sizeRawData         = bytecast(obj.rawData(maskSize),'L','uint16',cpuByteOrder); % get the actual size in words (1 word = 2 bytes)

  	% get a mask of id bytes that we know to not have size info in the data
    % record but we know the size anyways
    tmpList             = structMeta(maskNoSizeInDataYetKnown,:);
    [im,imInd]          = ismember(idsRawData,tmpList{:,'Id'});
    sizeRawData(im)     = tmpList{imInd(im),'SizeWords'}; % insert known sizes
    

    sizesFromSync       = 0.5.*diff(find([maskSync; true]));
    isSizeConsistent    = sizesFromSync == sizeRawData;
    hasSizeBuffer       = sizesFromSync >= sizeRawData;
    nUnusedBytes        = sum(hasSizeBuffer) - sum(isSizeConsistent);
    
    if nUnusedBytes > 0 && obj.debugger.debugLevel >= 'Warning'
        warning('%d sections with unused bytes were found and skipped.\n',nUnusedBytes);
    end

    isSizeConsistent    = hasSizeBuffer;
    % most of the time inconsistencies are due to false Sync detection,
    % a false Sync will divide a section in multiple pairs
    isPairInconsistent = [false; (~isSizeConsistent(1:end-1) & ~isSizeConsistent(2:end))];

    % when several inconsistent pairs in a row (next to each other), we only 
    % want to remove one at a time (the last one)
    isPairInconsistent = [xor(isPairInconsistent(1:end-1), isPairInconsistent(2:end)); false] & isPairInconsistent;

    while any(isPairInconsistent)
        maskSync(maskSync)  = ~isPairInconsistent;

        maskIds             = shiftMask(maskSync,1,1); % get mask for remaining ids (1 byte after sync byte, 1 byte long)
        idsRawData       	= obj.rawData(maskIds); % get the actual ids
        maskSize            = shiftMask(maskSync,2,2); % get mask for size in data (2 bytes after sync byte, 2 bytes long)
        sizeRawData         = bytecast(obj.rawData(maskSize),'L','uint16',cpuByteOrder); % get the actual size in words (1 word = 2 bytes)

        % get a mask of id bytes that we know to not have size info in the data
        % record but we know the size anyways
        tmpList             = structMeta(maskNoSizeInDataYetKnown,:);
        [im,imInd]          = ismember(idsRawData,tmpList{:,'Id'});
        sizeRawData(im)     = tmpList{imInd(im),'SizeWords'}; % insert known sizes

        sizesFromSync       = 0.5.*diff(find([maskSync; true]));
        isSizeConsistent    = sizesFromSync >= sizeRawData;
        isPairInconsistent  = [false; (~isSizeConsistent(1:end-1) & ~isSizeConsistent(2:end))];
        isPairInconsistent  = [xor(isPairInconsistent(1:end-1), isPairInconsistent(2:end)); false] & isPairInconsistent;
    end
  	if obj.debugger.debugLevel >= 'Verbose'
        nSyncBytes(4)   = sum(maskSync);
        fprintf('VERBOSE: Finding data structures... # sync ids remaining: %d (%d)\n',nSyncBytes(4),diff(nSyncBytes(3:4)));
    end

    % now we need to deal with any fault sync detection left alone
    if any(~isSizeConsistent)
        maskSync(maskSync) = [true; isSizeConsistent(1:end-1)];

        % we also handle the case when the last section has been truncated so 
        % that we don't try to read it at all
        if ~isSizeConsistent(end)
            maskSync(maskSync) = [true(sum(maskSync)-1, 1); false];
        end

        maskIds             = shiftMask(maskSync,1,1); % get mask for remaining ids (1 byte after sync byte, 1 byte long)
        idsRawData       	= obj.rawData(maskIds); % get the actual ids
        maskSize            = shiftMask(maskSync,2,2); % get mask for size in data (2 bytes after sync byte, 2 bytes long)
        sizeRawData         = bytecast(obj.rawData(maskSize),'L','uint16',cpuByteOrder); % get the actual size in words (1 word = 2 bytes)

        % get a mask of id bytes that we know to not have size info in the data
        % record but we know the size anyways
        tmpList             = structMeta(maskNoSizeInDataYetKnown,:);
        [im,imInd]          = ismember(idsRawData,tmpList{:,'Id'});
        sizeRawData(im)     = tmpList{imInd(im),'SizeWords'}; % insert known sizes
    end
    
  	if obj.debugger.debugLevel >= 'Verbose'
        nSyncBytes(5)   = sum(maskSync);
        fprintf('VERBOSE: Finding data structures... # sync ids remaining: %d (%d)\n',nSyncBytes(5),diff(nSyncBytes(4:5)));
    end
   	if obj.debugger.debugLevel >= 'Info'
        fprintf('VERBOSE: Finding data structures... done\n');
    end
    nStructures     = numel(sizeRawData);

	%% TEST CHECKSUMS 
	if obj.debugger.debugLevel >= 'Info'
        fprintf('INFO: testing checksums ...');
	end
    
    indSync             = zeros(sum(maskSync),3,'uint32');
    indSync(:,1)        = (find(maskSync) - 1)./2 + 1; % in words
    indSync(:,2)        = indSync(:,1) + uint32(sizeRawData) - 1;
        
    % calculate checksums
    rawDataWords        = uint16(bytecast(obj.rawData,'L','uint16',cpuByteOrder));
    indSync(:,3)       	= arrayfun(@(s,e) sum(rawDataWords(s:e - 1)),indSync(:,1),indSync(:,2));
    checksumCalculated  = mod(46476 + indSync(:,3),2^16);
    
    maskChecksum                        = false(nBytes,1);
    maskChecksum(indSync(:,2).*2 - 1)	= true;
    maskChecksum                    	= shiftMask(maskChecksum,0,2);
    
    rawDataChecksum     = obj.rawData(maskChecksum);
    checksumExpected    = bytecast(rawDataChecksum,'L','uint16',cpuByteOrder);
    
    checksumOk          = checksumExpected == checksumCalculated;
    
    nChecksumNotOk      = nStructures - sum(checksumOk);
    
	if obj.debugger.debugLevel >= 'Info'
        fprintf(' done\n');
	end
	if obj.debugger.debugLevel >= 'Warning'
        warning('%d of %d structures have an invalid checksum.\n',nChecksumNotOk,nStructures);
	end
    
    %% OUTPUT
    ind     = struct('OffsetInBytes',find(maskSync),...
                     'SizeInBytes',uint16(2.*sizeRawData),...
                     'Id',idsRawData,...
                     'ChecksumOk',checksumOk);
                 
	%% SAVE INDEX FILE
    save(indexFilename,'ind','-v7.3')
    
   	if obj.debugger.debugLevel >= 'Info'
     	fprintf('INFO: finished file indexing. %d data structures were found.\n      These structure Ids were found: %s.\n',size(ind.OffsetInBytes,1),strjoin(cellstr(num2str(unique(ind.Id))),', '));
    end
end

function maskShifted = shiftMask(maskIn,s,n)
    maskShifted     = [false(s,1); maskIn(1:end - s)];
    for ii = 1:n - 1
        maskShifted     = maskShifted | ...
                          [false(s + ii,1); maskIn(1:end - (s + ii))];
    end
end