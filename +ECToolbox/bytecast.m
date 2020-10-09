function outBytes = bytecast(inBytes,inByteOrder,outType,varargin)
    narginchk(3,4);
    
    if nargin == 3
        [~,~,cpuByteOrder] = computer;
    elseif nargin == 4
        cpuByteOrder = varargin{1};
    end
    
    if cpuByteOrder == inByteOrder
        try
            outBytes = typecast(inBytes, outType);
        catch ME
            switch ME.identifier
                case 'MATLAB:typecastc:notEnoughInputElements'
                    outTypeLength   = getTypeLength(outType);
                    inBytesExtra    = mod(numel(inBytes),outTypeLength);
                    outBytes        = typecast(inBytes(1:end - inBytesExtra),outType);
                    
                    warning('bytecast:notEnoughInputElements',...
                            'Wrong number of input bytes. %d bytes at the end were ignored.',inBytesExtra)
                otherwise
                    rethrow(ME);
            end
        end
    else
        swappedBytes    = swapbytes(inBytes);
        try
            outBytes        = typecast(swappedBytes, outType);
        catch ME
            switch ME.identifier
                case 'MATLAB:typecastc:notEnoughInputElements'
                    outTypeLength   = getTypeLength(outType);
                    inBytesExtra    = mod(numel(inBytes),outTypeLength);
                    outBytes        = typecast(swappedBytes(1:end - inBytesExtra),outType);
                    
                    warning('bytecast:notEnoughInputElements',...
                            '\nWrong number of input bytes. %d byte(s) at the end were ignored.',inBytesExtra)
                otherwise
                    rethrow(ME);
            end
            
        end
    end
    outBytes = double(outBytes);
    
    function typeLength = getTypeLength(type)
        types           = {'uint8','int8','uint16','int16','uint32','int32','uint64','int64','single','double'};
        typeLengths     = [1,1,2,2,4,4,8,8,4,8];
        typeLength      = typeLengths(ismember(types,type));
    end
end