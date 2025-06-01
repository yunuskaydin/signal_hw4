% Added the path of functions
addpath('./functions');

input_folder      = '../video_data/';
frame_files       = dir(fullfile(input_folder, '*.jpg'));
num_frames        = length(frame_files);

% Uncompressed video size in bits: 480 x 360 pixels x 24 bits x 120 frames
uncompressed_bits = 480 * 360 * 24 * 120;
% Test GOP sizes from 1 to 30
gops = 1:30;
% Stores bit sizes for each GOP
compressed_bits = zeros(size(gops));

for idx = 1:numel(gops)
    gop = gops(idx);
    % Output file name according to gop.
    outname = sprintf('result_gop%02d.bin', gop);
    fid = fopen(outname, 'w');
    prev_mb = [];

    for frame_idx = 1:num_frames
        % Reads frame and divide into macroblocks
        frame    = double(imread(fullfile(input_folder, frame_files(frame_idx).name)));
        mb_cells = frame_to_mb(frame);

        % Determines I-frame or P-frame
        is_iframe = mod(frame_idx-1, gop) == 0;
        fwrite(fid, is_iframe, 'uint8');

        % Compresses each  MB and channel
        for i = 1:45
            for j = 1:60
                block = mb_cells{i,j};
                if is_iframe
                    % Direct compression
                    [rle, len] = compress_block(block);
                else
                    % Residual for P-frame
                    residual   = block - prev_mb{i,j};
                    [rle, len] = compress_block(residual);
                end
                for ch = 1:3
                    fwrite(fid, len(ch),    'int16');
                    fwrite(fid, rle{ch},    'int16');
                end
            end
        end
        % Updates reference for next frame
        prev_mb = mb_cells;
    end

    fclose(fid);

    % Calculate total compressed size in bits
    info = dir(outname);
    compressed_bits(idx) = info.bytes * 8;
end

% Computes and plots compression ratio
ratio = compressed_bits ./ uncompressed_bits;

figure;
plot(gops, ratio, '-o', 'LineWidth', 1.5);
xlabel('GOP size');
ylabel('Compressed\_bits / Uncompressed\_bits');
title('Compression Ratio vs GOP Size');
grid on;
