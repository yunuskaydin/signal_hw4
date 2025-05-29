% eval_gop_compression.m

addpath('./functions');

input_folder      = '../video_data/';
frame_files       = dir(fullfile(input_folder, '*.jpg'));
num_frames        = length(frame_files);
uncompressed_bits = 480 * 360 * 24 * 120;  % as given

gops            = 1:30;
compressed_bits = zeros(size(gops));

for idx = 1:numel(gops)
    gop = gops(idx);
    outname = sprintf('result_gop%02d.bin', gop);
    fid = fopen(outname, 'w');
    prev_mb = [];   % clear reference frame

    for frame_idx = 1:num_frames
        %–– read and split into macroblocks
        frame    = double(imread(fullfile(input_folder, frame_files(frame_idx).name)));
        mb_cells = frame_to_mb(frame);

        %–– decide I-frame or P-frame
        is_iframe = mod(frame_idx-1, gop) == 0;
        fwrite(fid, is_iframe, 'uint8');

        %–– compress each  MB and channel
        for i = 1:45
            for j = 1:60
                block = mb_cells{i,j};
                if is_iframe
                    [rle, len] = compress_block(block);
                else
                    residual   = block - prev_mb{i,j};
                    [rle, len] = compress_block(residual);
                end
                for ch = 1:3
                    fwrite(fid, len(ch),    'int16');
                    fwrite(fid, rle{ch},    'int16');
                end
            end
        end

        prev_mb = mb_cells;
    end

    fclose(fid);

    %–– file size in bits
    info = dir(outname);
    compressed_bits(idx) = info.bytes * 8;
end

%–– compute and plot compression ratio
ratio = compressed_bits ./ uncompressed_bits;

figure;
plot(gops, ratio, '-o', 'LineWidth', 1.5);
xlabel('GOP size');
ylabel('Compressed\_bits / Uncompressed\_bits');
title('Compression Ratio vs GOP Size');
grid on;
