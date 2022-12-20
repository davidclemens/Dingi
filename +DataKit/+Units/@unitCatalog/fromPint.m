function obj = fromPint(file)
    
    % Initialize unitCatalog
    obj = DataKit.Units.unitCatalog;
    
    % Open pint file and read it
    fId = fopen(file,'r');
    raw = textscan(fId,'%s',...
        'CollectOutput',    false,...
        'CommentStyle',     '#',...
        'Delimiter',        '\n',...
        'Whitespace',       '');
    fclose(fId);
    raw = raw{1};
    
    % Identify line types
    isEmpty         = cellfun(@isempty,raw);
    isPrefix        = ~cellfun(@isempty,regexp(raw,'^\w+\-\s=\s'));
    isUnit          = ~cellfun(@isempty,regexp(raw,'^\w+\s=\s'));
    isDimension     = ~cellfun(@isempty,regexp(raw,'^\[\w+\]\s=\s'));
    isGroupWrapper  = ~cellfun(@isempty,regexp(raw,'^@\w+'));
    isGroupContent  = ~cellfun(@isempty,regexp(raw,'^\s+[#\[\w]+'));
    
    % Check if all lines were identified
    parsingCheck = cat(2,isEmpty,isPrefix,isUnit,isDimension,isGroupWrapper,isGroupContent);
    if any(sum(parsingCheck,2) > 1) || ~all(any(parsingCheck,2))
        error('Parsing error')
    end
    
    % Make compatible with MATLAB syntax
    % Replace power operator '**' with '^'
    raw(~isEmpty & ~isGroupWrapper) = regexprep(raw(~isEmpty & ~isGroupWrapper),'(?<=.+)\*{2}(?=.+)','^');
    
    % Remove spaces around operators
    raw(~isEmpty & ~isGroupWrapper) = regexprep(raw(~isEmpty & ~isGroupWrapper),'\s(\+|\-|\*|/|\^)\s','$1');
    
    % Parse lines
    tblPrefix   	= parsePrefix(raw(isPrefix));
    tblUnit         = parseUnit(raw(isUnit));
    tblDimension	= parseDimension(raw(isDimension));
    
    % Add to unitCatalog
    obj.addPrefix(tblPrefix{:,'name'},tblPrefix{:,'value'},tblPrefix{:,'symbol'},tblPrefix{:,'alias'})
    obj.addDimension(tblDimension{:,'name'},tblDimension{:,'parents'},tblDimension{:,'exponents'})
    
    function tbl = parsePrefix(raw)
    % parsePrefix  Parse prefix line
    %   PARSEPREFIX parses a prefix line and returns a table with variables 'name',
    %   'value', 'symbol' & 'alias'.
    %

        % Define defaults
        defaultSymbol   = {''};
        defaultAlias    = {{}};
        
        % Split each line at '='
        rawPrefix = regexp(raw,'\s=\s','split');
        for ii = 1:numel(rawPrefix)
            l = numel(rawPrefix{ii});

            if l == 2
                % Only name & value are provided
                rawPrefix{ii} = cat(2,rawPrefix{ii},defaultSymbol,defaultAlias);
            elseif l == 3
                % Only name, value & symbol are provided
                rawPrefix{ii} = cat(2,rawPrefix{ii},defaultAlias);
            elseif l > 3
                % All name, value, symbol & alias(es) are provided
                rawPrefix{ii} = cat(2,rawPrefix{ii}(1:3),{rawPrefix{ii}(4:end)});
            elseif l < 2
                % Invalid prefix definition line
                error('Dingi:DataKit:Units:unitCatalog:fromPint:parsePrefix:InvalidLine',...
                    'Line %u in file ''%s'' is not a valid prefix definition:\n\t''%s''',find(isPrefix,ii),file,raw{ii})
            end 
        end
        
        % Convert to table
        varNamesPrefix  = {'name','value','symbol','alias'};
        tbl = cell2table(cat(1,rawPrefix{:}),'VariableNames',varNamesPrefix);

        % Remove '-' suffix in name, symbol & alias
        tbl{:,{'name','symbol'}} = regexprep(tbl{:,{'name','symbol'}},'\-$','');
        tbl{:,'alias'} = cellfun(@(c) regexprep(c,'\-$',''),tbl{:,'alias'},'un',0);

        % Remove '_' in symbol
        tbl{:,'symbol'} = regexprep(tbl{:,'symbol'},'^_$','');

        % Convert value to number
        tbl.value = cat(1,cellfun(@eval,tbl{:,'value'},'un',1));
    end
    function tbl = parseUnit(raw)
    % parseUnit  Parse unit line
    %   PARSEUNIT parses a unit line and returns a table with variables 'name',
    %   'link', 'symbol' & 'alias'.
    %
    
        % Define defaults
        defaultSymbol   = {''};
        defaultAlias    = {{}};
        
        % Split each line at '='
        rawUnit	= regexp(raw,'\s=\s','split');
        for ii = 1:numel(rawUnit)
            l = numel(rawUnit{ii});

            if l == 2
                % Only name & link are provided
                rawUnit{ii} = cat(2,rawUnit{ii},defaultSymbol,defaultAlias);
            elseif l == 3
                % Only name, link & symbol are provided
                rawUnit{ii} = cat(2,rawUnit{ii},defaultAlias);
            elseif l > 3
                % All name, link, symbol & alias(es) are provided
                rawUnit{ii} = cat(2,rawUnit{ii}(1:3),{rawUnit{ii}(4:end)});
            elseif l < 2
                % Invalid prefix definition line
                error('Dingi:DataKit:Units:unitCatalog:fromPint:parseUnit:InvalidLine',...
                    'Line %u in file ''%s'' is not a valid unit definition:\n\t''%s''',find(isUnit,ii),file,raw{ii})
            end 
        end
        
        % Convert to table
        varNamesPrefix  = {'name','link','symbol','alias'};
        tbl = cell2table(cat(1,rawUnit{:}),'VariableNames',varNamesPrefix);

        % Remove '_' in symbol
        tbl{:,'symbol'} = regexprep(tbl{:,'symbol'},'^_$','');
    end
    function tbl = parseDimension(raw)
    % parseDimension  Parse dimension line
    %   PARSEDIMENSION parses a dimension line and returns a table with variables
    %   'name' & 'parentsExpression'.
    %
        
        % Split each line at '='
        rawDimension	= regexp(raw,'\s=\s','split');
        for ii = 1:numel(rawDimension)
            l = numel(rawDimension{ii});

            if l < 2 || l > 2
                % Invalid prefix definition line
                error('Dingi:DataKit:Units:unitCatalog:fromPint:parseDimension:InvalidLine',...
                    'Line %u in file ''%s'' is not a valid dimension definition:\n\t''%s''',find(isDimension,ii),file,raw{ii})
            end 
        end
        
        % Convert to table
        varNamesPrefix  = {'name','parentsExpression'};
        tbl = cell2table(cat(1,rawDimension{:}),'VariableNames',varNamesPrefix);
        
        % Parse expressions
        p = DataKit.Units.Parser.parser();
        tbl{:,'parents'} = {''};
        tbl{:,'exponents'} = {[]};
        for ii = 1:numel(rawDimension)
            p(ii,1) = DataKit.Units.Parser.parser(tbl{ii,'parentsExpression'}{:},'Expression');
            try
            [parentDimensionNames,parentDimensionExponents] = p(ii).Tree.getDimensionality;
            catch ME
                switch ME.identifier
                    case 'Dingi:DataKit:Units:Parser:evalTreeNode:getDimensionality:NonMultiplicativeDimensionExpression'
                        error('Dingi:DataKit:Units:unitCatalog:fromPint:NonMultiplicativeDimensionExpression',...
                            'The dimension expression ''%s'' is not multiplicative and therefore an invalid dimension definition.',tbl{ii,'parentsExpression'}{:})
                    otherwise
                        rethrow(ME)
                end
            end
            tbl{ii,'parents'}{1} = parentDimensionNames;
            tbl{ii,'exponents'}{1} = parentDimensionExponents;
        end
    end
end
