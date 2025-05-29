function [rle_blocks, lengths] = compress_block(block)
    rle_blocks = cell(1,3);  % One for each color channel
    lengths = zeros(1,3);
    for ch = 1:3
        dct_block = dct2(block(:,:,ch));
        q = round(dct_block ./ QMatrix());
        zz = zigzag_scan(q);
        rle = run_length_encode(zz);
        rle_blocks{ch} = rle;
        lengths(ch) = length(rle);
    end
end
