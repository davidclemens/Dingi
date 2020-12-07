function tbl = listAllVariableInfo()

    
    variableList    = enumeration('DataKit.Metadata.variable');
    variableProps           = properties('DataKit.Metadata.variable');

    propClass   = cellfun(@class,cellfun(@(p) variableList(1).(p),variableProps,'un',0),'un',0);
    tblStruct   = struct();
    for prop = 1:numel(variableProps)
        switch propClass{prop}
            case 'char'
                column  = {variableList(:).(variableProps{prop})}';
            case {'single','double','int8','int16','int32','uint8','uint16','uint32','uint64'}
                column  = cat(1,variableList(:).(variableProps{prop}));
            otherwise
                error('%s is not implemented yet.',propClass{prop})
        end

        tblStruct.(variableProps{prop})     = column;
    end
    tbl             = struct2table(tblStruct);
    tbl.Variable	= variableList;
end