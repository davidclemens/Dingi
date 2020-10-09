function rawData = readRawData(obj)

    % open file
    try
        fileID      = fopen(obj.fileInfo.full,'r',obj.fileInfo.bitOrder);
        rawData     = fread(fileID,inf,'uint8=>uint8');
        fclose(fileID);
    catch err
        if fileID == -1
            % check if file exist
            if 2 ~= exist(obj.fileInfo.full,'file')
                error('The requested file ''%s'' does not exist',[obj.fileInfo.name,obj.fileInfo.ext])
            else
                error('The requested file ''%s'' exists but is not a valid file or not reachable',[obj.fileInfo.name,obj.fileInfo.ext])
            end
        else
            rethrow err;
        end
    end
end