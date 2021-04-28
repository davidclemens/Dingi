function intout = setbits(bits)

    intout = 0;
    for ii = 1:numel(bits)
        intout = bitset(intout,bits(ii),1);
    end
end