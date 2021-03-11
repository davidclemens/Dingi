function updateFlagsList(obj)

    flagsList               = table();
    flagsList.Flag          = enumeration('DataKit.Metadata.validators.validFlag');
    flagsList.Label         = cellstr(flagsList.Flag);
    
    % Remove 'undefined' flag from list
    flagsList(flagsList{:,'Flag'} == 'undefined',:) = [];
    
    obj.FlagsList           = flagsList;
end