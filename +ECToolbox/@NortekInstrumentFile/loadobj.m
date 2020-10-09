function obj = loadobj(sobj)
    obj = sobj;
    
    % read raw data
    obj.rawData                 = obj.readRawData();

    % create fileIndex & test checksums
    obj.fileIndex               = obj.createFileIndex();
end