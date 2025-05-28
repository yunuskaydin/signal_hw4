input_file = 'result_improved.bin';
output_folder = './decompressed_improved/';
mkdir(output_folder);

frame_files = dir('./video_data/*.jpg');
num_frames = length(frame_files);
fid = fopen(input_file, 'r');

prev_mb = [];

for frame_idx = 1:num_frames
    is_iframe = fread(fid, 1, 'uint8');
    mb_cells = cell(45, 60);

    for i = 1:45
        for j = 1:60
            dy_dx = fread(fid, 2, 'int8');
            dy = dy_dx(1);
            dx = dy_dx(2);

            block = zeros(8, 8, 3);
            for ch = 1:3
                len = fread(fid, 1, 'int16');
                rle = fread(fid, len, 'int16');
                zz = run_length_decode(rle);
                q = inverse_zigzag(zz, 8, 8);
                dct_block = q .* QMatrix();
                block(:,:,ch) = idct2(dct_block);
            end

            if ~is_iframe
                ref_i = i + dy;
                ref_j = j + dx;
                if ref_i >= 1 && ref_j >= 1 && ref_i <= 45 && ref_j <= 60
                    ref_block = prev_mb{ref_i, ref_j};
                    block = block + ref_block;
                end
            end

            mb_cells{i,j} = block;
        end
    end

    prev_mb = mb_cells;
    frame = uint8(mb_to_frame(mb_cells));
    imwrite(frame, fullfile(output_folder, frame_files(frame_idx).name));
end

fclose(fid);
