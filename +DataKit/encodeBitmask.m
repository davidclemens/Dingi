function encoded = encodeBitmask(encodedNum,bits)

    nBits   = numel(bits);
    encoded = uint16(encodedNum);
    for bb = 1:nBits
        encoded = bitset(encoded,bits(bb),'uint16');
    end
end