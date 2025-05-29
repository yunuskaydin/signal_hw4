addpath('./functions');

input_file = '../outputs/result.bin';
output_folder = '../outputs/decompressed/';
mkdir(output_folder);

frame_files = dir('../video_data/*.jpg');
num_frames = length(frame_files);
fid = fopen(input_file, 'r');

prev_mb = [];

for frame_idx = 1:num_frames
    is_iframe = fread(fid, 1, 'uint8');
    mb_cells = cell(45, 60);

    for i = 1:45
        for j = 1:60
            block = decompress_block(fid);
            if ~is_iframe
                block = prev_mb{i,j} + block;
            end
            mb_cells{i,j} = block;
        end
    end

    prev_mb = mb_cells;
    frame = uint8(mb_to_frame(mb_cells));
    imwrite(frame, fullfile(output_folder, frame_files(frame_idx).name));
end

fclose(fid);
