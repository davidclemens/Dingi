function tbl = core_listMembersInfo(classname)

% 	[~,L]	= enumeration(classname);
    
    
    variableList    = enumeration(classname);
    variableProps	= properties(classname);
    
    classHierarchy	= strsplit(classname,'.');
    classTableName 	= [upper(classHierarchy{end}(1)),classHierarchy{end}(2:end)];

    propClass   = cellfun(@class,cellfun(@(p) variableList(1).(p),variableProps,'un',0),'un',0);
    tblStruct   = struct();
    for prop = 1:numel(variableProps)
        switch propClass{prop}
            case 'char'
                column  = {variableList(:).(variableProps{prop})}';
            case {'single','double','int8','int16','int32','uint8','uint16','uint32','uint64'}
                column  = cat(1,variableList(:).(variableProps{prop}));
            otherwise
                error('Dingi:DataKit:enum:core_listMembersInfo:TODO',...
                    'TODO: ''%s'' is not implemented yet.',propClass{prop})
        end

        tblStruct.(variableProps{prop})     = column;
    end
    tbl             = struct2table(tblStruct);
    
    tbl.(classTableName)	= variableList;
    % The following rearranging is commented out, since ther is a bug in
    % MATLAB's table.disp() method, where enums are not padded correctly,
    % which messes up the command output. By leaving the enum column as the
    % last column, the command output remains readable.
    % tbl                     = tbl(:,[{classTableName},variableProps']);
end