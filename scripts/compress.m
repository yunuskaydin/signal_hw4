% Added the functions path
addpath('./functions');

% Ensured that if the folder doesn't exist matlab creates it.
if ~exist('../outputs/compressed', 'dir')
    mkdir('../outputs/compressed');
end

% Got the input from video_data folder
input_folder = '../video_data/';

% Ensured that if the gop_size doesn't exist it's set to 15 as default.
if ~exist('gop_size', 'var')
    gop_size = 15;
end

% Construct the output file name based on GOP size
output_file = sprintf('../outputs/compressed/result_gop%02d.bin', gop_size);

% Gathered the list of frame files.
frame_files = dir(fullfile(input_folder, '*.jpg'));
num_frames = length(frame_files);
fid = fopen(output_file, 'w');

prev_mb = [];

for frame_idx = 1:num_frames
    % Reads and converts image to double
    frame = double(imread(fullfile(input_folder, frame_files(frame_idx).name)));
    % Splits image into 8x8x3 macroblocks
    mb_cells = frame_to_mb(frame);
    % Determines if this frame is an I-frame
    is_iframe = mod(frame_idx - 1, gop_size) == 0;
    % Write frame type
    fwrite(fid, is_iframe, 'uint8');
    % Processed each macroblock
    for i = 1:45
        for j = 1:60
            block = mb_cells{i,j};
    
            if is_iframe
                [rle_blocks, lengths] = compress_block(block);
            else
                residual = block - prev_mb{i,j};
                [rle_blocks, lengths] = compress_block(residual);
            end
    
            for ch = 1:3
                fwrite(fid, lengths(ch), 'int16');         
                fwrite(fid, rle_blocks{ch}, 'int16');      
            end
        end
    end

    % Stored current frame macroblocks for next P-frame
    prev_mb = mb_cells;
end
% Closed the output file
fclose(fid);
