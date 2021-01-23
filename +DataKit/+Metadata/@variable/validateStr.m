function [bool,info] = validateStr(str)
    
    if iscellstr(str)
        % ok
    elseif ischar(str)
        str = cellstr(str);
    else
        error('Dingi:DataKit:Metadata:variable:validateStr:invalidStringDataType',...
            '''str'' has to be either a char vector or a cellstr.')
    end

    nVariables  = numel(str);
    infoAll     = DataKit.Metadata.variable.listAllVariableInfo;
    info        = repmat(DataKit.table2emptyRow(infoAll),nVariables,1);
    id          = zeros(numel(str),1,'uint16');
    for s = 1:nVariables
        try
            var     = DataKit.Metadata.variable.str2variable(str(s));
            id(s)   = var.variable2id;
        catch ME
            switch ME.identifier
                case 'MATLAB:class:CannotConvert'
                    if isempty(regexpi(ME.message,'is not a member of enumeration ''DataKit.Metadata.variable'''))
                       rethrow(ME);
                    end
                otherwise
                    rethrow(ME);
            end
        end
    end
    
    bool            = id > 0;
    [~,imIdx]       = ismember(id,infoAll{:,'Id'});
    info(bool,:)	= infoAll(imIdx(bool),:);
end