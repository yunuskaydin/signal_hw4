% Added the functions path
addpath('./functions');

% Ensured that if the gop_size doesn't exist it's set to 15 as default.
if ~exist('gop_size', 'var')
    gop_size = 15;
end
% Gets the input from the path that has compressed binary input
input_file = sprintf('../outputs/compressed/result_gop%02d.bin', gop_size);
output_folder = '../outputs/decompressed/';
mkdir(output_folder);

% Load frame file names in order to have consistent output naming
frame_files = dir('../video_data/*.jpg');
num_frames = length(frame_files);
fid = fopen(input_file, 'r');
% Holds macroblocks from previous frame
prev_mb = [];

for frame_idx = 1:num_frames
    is_iframe = fread(fid, 1, 'uint8');
    mb_cells = cell(45, 60);
    % Processes each macroblock
    for i = 1:45
        for j = 1:60
            block = decompress_block(fid);
            if ~is_iframe
                block = prev_mb{i,j} + block;
            end
            mb_cells{i,j} = block;
        end
    end
    % Stores macroblocks for future reference
    prev_mb = mb_cells;
    % Reconstructs and saves the full image frame
    frame = uint8(mb_to_frame(mb_cells));
    imwrite(frame, fullfile(output_folder, frame_files(frame_idx).name));
end

fclose(fid);
