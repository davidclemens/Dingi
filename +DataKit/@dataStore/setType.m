function setType(obj,type)
% setType  Sets the data type of the dataStore
%   SETTYPE sets the data type in which the dataStore data is stored in memory.

    % Validate inputs
    validTypes = {'single','double','int8','uint8','int16','uint16','int32','uint32','int64','uint64'};
    type    = validatestring(type,validTypes,mfilename,'type',2);
    
    % Change the type, if it differs from the current one
    oldType     = obj.Type;
    if ~strcmp(type,oldType)
        obj.Data = cast(obj.Data,type);
        obj.Type = type;
        warning('Dingi:DataKit:dataStore:setType:newType',...
            'The data type of dataStore ''%s'' was changed from %s to %s.',inputname(1),oldType,type)
    end
end
