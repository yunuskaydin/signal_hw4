addpath('./functions');

input_folder = '../video_data/';

if ~exist('../outputs', 'dir')
    mkdir('../outputs');
end

if ~exist('gop_size', 'var')
    gop_size = 15;  % default if not passed in
end

output_file = sprintf('../outputs/result_improved_gop%02d.bin', gop_size);

frame_files = dir(fullfile(input_folder, '*.jpg'));
num_frames = length(frame_files);
fid = fopen(output_file, 'w');

prev_mb = [];

for frame_idx = 1:num_frames
    frame = double(imread(fullfile(input_folder, frame_files(frame_idx).name)));
    mb_cells = frame_to_mb(frame);
    is_iframe = mod(frame_idx - 1, gop_size) == 0;

    fwrite(fid, is_iframe, 'uint8');  % store frame type

    for i = 1:45
        for j = 1:60
            block = mb_cells{i,j};

            if is_iframe
                [rle_blocks, lengths] = compress_block(block);
                fwrite(fid, [0 0], 'int8');  % dummy motion vectors for I-frames
            else
                % Use motion estimation to find best matching block
                [best_block, dy, dx] = motion_estimate(block, prev_mb, i, j);
                residual = block - best_block;
                [rle_blocks, lengths] = compress_block(residual);
                fwrite(fid, [dy dx], 'int8');  % write motion vectors
            end

            for ch = 1:3
                fwrite(fid, lengths(ch), 'int16');          % Write length
                fwrite(fid, rle_blocks{ch}, 'int16');       % Write data
            end
        end
    end

    prev_mb = mb_cells;
end

fclose(fid);
