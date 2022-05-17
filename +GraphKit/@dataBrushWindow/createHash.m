function hash = createHash(data)
    
    outputFormat    = 'hex';
    method          = 'SHA-256'; % 'SHA-1', 'SHA-256', 'SHA-384', 'SHA-512', 'MD2', 'MD5'
    
    engine = java.security.MessageDigest.getInstance(method);
    
    engine = doHash(data,engine);
    
    hash = typecast(engine.digest, 'uint8');

    switch outputFormat
       case 'hex'
          hash = sprintf('%.2x', double(hash));
       case 'HEX'
          hash = sprintf('%.2X', double(hash));
       case 'double'
          hash = double(reshape(hash, 1, []));
       case 'uint8'
          hash = reshape(hash, 1, []);
       case 'short'
          hash = fBase64_enc(double(hash), 0);
       case 'base64'
          hash = fBase64_enc(double(hash), 1);
       otherwise
          Error_L('BadOutFormat', ...
             '[Opt.Format] must be: HEX, hex, uint8, double, base64.');
    end
    
    function engine = doHash(data,engine)
        
        if iscell(data)
            for ii = 1:numel(data)
                engine = doHash(data{ii},engine);
            end
        elseif islogical(data)
            engine.update(typecast(uint8(data(:)),'uint8'));
        end
    end
end