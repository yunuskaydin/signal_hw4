% Added the functions path
addpath('./functions');

input_folder = '../video_data/';

% Ensured that if the folder doesn't exist matlab creates it.
if ~exist('../outputs/compressed_improved', 'dir')
    mkdir('../outputs/compressed_improved');
end

% Ensured that if the gop_size doesn't exist it's set to 15 as default.
if ~exist('gop_size', 'var')
    gop_size = 15; 
end
% Construct the output file name based on GOP size
output_file = sprintf('../outputs/compressed_improved/result_improved_gop%02d.bin', gop_size);

% Gathered the list of frame files.
frame_files = dir(fullfile(input_folder, '*.jpg'));
num_frames = length(frame_files);
fid = fopen(output_file, 'w');

prev_mb = [];

for frame_idx = 1:num_frames
    % Load frame and convert to double
    frame = double(imread(fullfile(input_folder, frame_files(frame_idx).name)));
    mb_cells = frame_to_mb(frame);
    is_iframe = mod(frame_idx - 1, gop_size) == 0;

    fwrite(fid, is_iframe, 'uint8');  % store frame type

    for i = 1:45
        for j = 1:60
            block = mb_cells{i,j};

            if is_iframe
                % I-frame: compress directly, no motion vector needed
                [rle_blocks, lengths] = compress_block(block);
                fwrite(fid, [0 0], 'int8'); 
            else
                % Use motion estimation to find best matching block if it's
                % not I-frame
                [best_block, dy, dx] = motion_estimate(block, prev_mb, i, j);
                residual = block - best_block;
                [rle_blocks, lengths] = compress_block(residual);
                fwrite(fid, [dy dx], 'int8');
            end

            for ch = 1:3
                fwrite(fid, lengths(ch), 'int16');          
                fwrite(fid, rle_blocks{ch}, 'int16');       
            end
        end
    end
    % Saves current frame macroblocks for next frame's reference
    prev_mb = mb_cells;
end

fclose(fid);
