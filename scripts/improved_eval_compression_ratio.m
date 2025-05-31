% improved_eval_compression_ratio.m
addpath('./functions');

input_folder = '../video_data/';
frame_files = dir(fullfile(input_folder, '*.jpg'));
num_frames = length(frame_files);
uncompressed_bits = 480 * 360 * 24 * 120;  % 62 MB

gops = 1:30;
compressed_bits = zeros(size(gops));

for idx = 1:numel(gops)
    gop_size = gops(idx);   % Global değişken olarak tanımlı olsun diye
    improved_compress;      % result_improved_gopXX.bin dosyasını üretir
    
    outname = sprintf('../outputs/result_improved_gop%02d.bin', gop_size);
    info = dir(outname);
    compressed_bits(idx) = info.bytes * 8;  % bits
end

%–– Plot compression ratio
ratio = compressed_bits ./ uncompressed_bits;
figure;
plot(gops, ratio, '-o', 'LineWidth', 1.5);
xlabel('GOP Size');
ylabel('Compressed Bits / Uncompressed Bits');
title('Improved Compression Ratio vs GOP Size');
grid on;
