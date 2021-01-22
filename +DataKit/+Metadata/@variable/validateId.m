function [bool,info] = validateId(id)

    if isa(id,'uint16')
        % ok
    elseif ~isa(id,'uint16') && isnumeric(id)
        try
            id = cast(id,'uint16');
        catch ME
            rethrow(ME)
        end
    else
        error('Dingi:DataKit:Metadata:variable:validateId:invalidIdDataType',...
            '''id'' has to be either a uint16 vector or be convertible to uint16.')
    end
    
    nVariables  = numel(id);
    infoAll     = DataKit.Metadata.variable.listAllVariableInfo;
    info        = repmat(DataKit.table2emptyRow(infoAll),nVariables,1);
    idOut          = zeros(numel(id),1,'uint16');
    for s = 1:nVariables
        try
            var         = DataKit.Metadata.variable.id2variable(id(s));
            idOut(s)	= var.variable2id;
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
    
    bool            = idOut > 0;
    [~,imIdx]       = ismember(idOut,infoAll{:,'Id'});
    info(bool,:)	= infoAll(imIdx(bool),:);
end