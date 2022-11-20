function obj = fromPint(file)
    
    fId = fopen(file,'r');
    raw = textscan(fId,'%s',...
        'CollectOutput',    false,...
        'CommentStyle',     '#',...
        'Delimiter',        '\n',...
        'Whitespace',       '');
    fclose(fId);
    raw = raw{1};
    
    isEmpty     = cellfun(@isempty,raw);
    isPrefix    = ~cellfun(@isempty,regexp(raw,'^\w+\-\s=\s'));
    isUnit      = ~cellfun(@isempty,regexp(raw,'^\w+\s=\s'));
    isDimension = ~cellfun(@isempty,regexp(raw,'^\[\w+\]\s=\s'));
    
    isGroupWrapper = ~cellfun(@isempty,regexp(raw,'^@\w+'));
    isGroupContent = ~cellfun(@isempty,regexp(raw,'^\s+[#\[\w]+'));
    
    
    parsingCheck = cat(2,isEmpty,isPrefix,isUnit,isDimension,isGroupWrapper,isGroupContent);
    if any(sum(parsingCheck,2) > 1) || ~all(any(parsingCheck,2))
        error('Parsing error')
    end
end
