function [bool,info] = validateId(id)

    if ~isnumeric(id)
        error('Dingi:DataKit:Metadata:dataFlag:validateId:invalidIdDataType',...
            '''id'' has to be numeric.')
    end
    
    infoAll         = DataKit.Metadata.validators.validFlag.listAllValidFlagInfo;
    [bool,imIdx]  	= ismember(id,infoAll{:,'Id'});
    info            = infoAll(imIdx(bool),:);
end