function data = getDataArray(obj,structId,offsets,type)
% GETDATAARRAY Reads data from data structures into an array
% Reads data of type type at an offset offset from a specified data
% structure ID structID in a NortekInstrumentFile object into a data array.
%
% Syntax
%   data = GETDATAARRAY(structID,offset,type)
%
% Description
%   data = GETDATAARRAY(structID,offset,type) reads data of
%       type type at an offset 'offset' from a specified data structure ID
%       'structID' in a NortekInstrumentFile object into a data array
%       'data'.
%
%
% Example(s)
%   data = GETDATAARRAY(16,5:6,'uint16')
%   data = GETDATAARRAY(16,[5,8],'uint16')
%   data = GETDATAARRAY(16,[5,8:9,20],'int32')
%
% Input Arguments
%   structId - Nortek data structure ID
%       numeric scalar
%       The structure ID of the data structure to read from.
%   offset - data offset(s) in bytes
%       numeric vectro
%       The offset(s) (bytes) from the sync byte in the data structure that
%       should be read. They can also be discontinuous.
%   type - data type
%       'int8' | 'uint8' | 'int16' | 'uint16' | 'int32' | 'uint32' | ...
%       Data type to read. E.g. 'uin32' would read the bytes from offset to
%       offset + 3.
%
%
% Name-Value Pair Arguments
%
%
% See also
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)


    % TODO implement input checks

    typeLength  = regexpi(type,'u?int(\d{1,2})','tokens');
    typeLength  = str2double(typeLength{:}{:})/8; % bytes

    if typeLength ~= numel(offsets)
        error('ECToolbox:NortekInstrumentFile:getDataArray:invalidNumberOfOffsets',...
          'The number of offsets given doesn''t match the data type.')
    end

    getInd      = reshape(obj.fileIndex.OffsetInBytes(obj.fileIndex.Id == structId)' + offsets(:),1,[])';
    badChecksum = ~obj.fileIndex.ChecksumOk(obj.fileIndex.Id == structId);
    data        = ECToolbox.bytecast(obj.rawData(getInd),'L',type);
    data(badChecksum)	= NaN;
end
