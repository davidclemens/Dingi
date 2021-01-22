function dt = BCD2datetime(bytes)
% BCD2DATETIME Converts 6 byte binary coded decimal (BCD) to datetime.
% Converts 6 byte binary coded decimal as used in Nortek files to datetime.
%
% Syntax
%   dt = BCD2DATETIME(bytes)
%
% Description
%   dt = BCD2DATETIME(bytes) converts the 6 BCD bytes 'bytes' to a datetime
%       object.
%
%
% Example(s) 
%
%
% Input Arguments
%   bytes - 6 BCD bytes
%       uint8
%       6 element BCD uint8. The bytes are orderd as:
%       minute, second, day, hour, year, month
%
%
% Name-Value Pair Arguments
%
% 
% See also
%
% Copyright (c) 2020-2021 David Clemens (dclemens@geomar.de)

    % input shape test
    shape       = size(bytes);
    if any(shape == 6)
        dim = find(shape == 6);
        if dim == 1
            bytes   = bytes';
        end
    end
    
    bytes       = bytes(:,[5,6,3,4,1,2])'; % reorder to get y,m,d,H,M,S
    dv          = decBCD2num(bytes)';
    dv(dv(:,1) >= 90,1)	= dv(dv(:,1) >= 90,1) + 1900;
    dv(dv(:,1) < 90,1)	= dv(dv(:,1) < 90,1) + 2000;
    dt          = datetime(dv);
    function num = decBCD2num(decBCD)
        sizeIn  = size(decBCD);
        decBCD  = decBCD(:);
        decBCD  = double(decBCD);
        decBCD	= min(decBCD,bin2dec('10011001'));
        c       = bitand(decBCD,bin2dec('00001111'),'uint8');
        num    	= c + 10*bitshift(decBCD,-4,'uint8');
        num     = reshape(num,sizeIn);
    end
end