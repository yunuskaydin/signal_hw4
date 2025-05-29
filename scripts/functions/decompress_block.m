function block = decompress_block(fid)
    block = zeros(8, 8, 3);
    for ch = 1:3
        len = fread(fid, 1, 'int16');  % Read length of RLE vector
        if isempty(len) || len <= 0 || len > 256
            error('Invalid or missing RLE length while decoding.');
        end
        rle = fread(fid, len, 'int16');
        if length(rle) < len
            error('Unexpected end of file or corrupted RLE block.');
        end
        zz = run_length_decode(rle);
        q = inverse_zigzag(zz, 8, 8);
        dct_block = q .* QMatrix();
        block(:,:,ch) = idct2(dct_block);
    end
end
