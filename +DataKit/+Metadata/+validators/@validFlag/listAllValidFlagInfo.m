function tbl = listAllValidFlagInfo()

    
    flagList   	= enumeration('DataKit.Metadata.validators.validFlag');
    flagProps	= properties('DataKit.Metadata.validators.validFlag');

    propClass   = cellfun(@class,cellfun(@(p) flagList(1).(p),flagProps,'un',0),'un',0);
    tblStruct   = struct();
    for prop = 1:numel(flagProps)
        switch propClass{prop}
            case 'char'
                column  = {flagList(:).(flagProps{prop})}';
            case {'single','double','int8','int16','int32','uint8','uint16','uint32','uint64'}
                column  = cat(1,flagList(:).(flagProps{prop}));
            otherwise
                error('%s is not implemented yet.',propClass{prop})
        end

        tblStruct.(flagProps{prop})     = column;
    end
    tbl     	= struct2table(tblStruct);
    tbl.Flag	= flagList;
end