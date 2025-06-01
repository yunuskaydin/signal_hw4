% Added the functions path
addpath('./functions');

% Ensured that if the gop_size doesn't exist it's set to 15 as default.
if ~exist('gop_size', 'var')
    gop_size = 15;
end
% Gets the input from the path that has compressed binary input
input_file = sprintf('../outputs/compressed_improved/result_improved_gop%02d.bin', gop_size);

output_folder = '../outputs/decompressed_improved/';
mkdir(output_folder);

% Load frame file names in order to have consistent output naming
frame_files = dir('../video_data/*.jpg');
num_frames = length(frame_files);
fid = fopen(input_file, 'r');

prev_mb = [];

for frame_idx = 1:num_frames
    is_iframe = fread(fid, 1, 'uint8');
    mb_cells = cell(45, 60);

    for i = 1:45
        for j = 1:60
            % Read motion vectors
            dy = fread(fid, 1, 'int8');
            dx = fread(fid, 1, 'int8');
            
            % Read and decode the block
            block = zeros(8, 8, 3);
            for ch = 1:3
                len = fread(fid, 1, 'int16');
                rle = fread(fid, len, 'int16');
                
                % Decode RLE and reconstruct block
                zz = run_length_decode(rle);
                q = inverse_zigzag(zz, 8, 8);
                dct_block = q .* QMatrix();
                block(:,:,ch) = idct2(dct_block);
            end
            
            if ~is_iframe
                % Get reference block using motion vectors
                ref_i = i + dy;
                ref_j = j + dx;
                if ref_i >= 1 && ref_j >= 1 && ref_i <= 45 && ref_j <= 60
                    block = block + prev_mb{ref_i,ref_j};
                end
            end
            
            mb_cells{i,j} = block;
        end
    end

    % Store current macroblocks as reference
    prev_mb = mb_cells;
    % Convert macroblocks back to image and save
    frame = uint8(mb_to_frame(mb_cells));
    imwrite(frame, fullfile(output_folder, frame_files(frame_idx).name));
end

fclose(fid);
