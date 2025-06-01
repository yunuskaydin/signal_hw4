% Added the path of functions
addpath('./functions');

input_folder = '../video_data/';
output_folder = '../outputs/decompressed/';
frame_files = dir(fullfile(input_folder, '*.jpg'));
num_frames = length(frame_files);
gopSizes = [1, 15, 30];
% Maximum pixel value for 8-bit images
MAX_I = 255;

% Load original video frames
orig = cell(1, num_frames);
for k = 1:num_frames
    orig{k} = double(imread(fullfile(input_folder, frame_files(k).name)));
end

% Preallocate PSNR values for each GOP size and frame
psnrVals = zeros(numel(gopSizes), num_frames);

for gi = 1:numel(gopSizes)
    gop_size = gopSizes(gi);   
    
    % Encodes using the basic algorithm
    compress;

    % Decodes the binary stream
    decompress;

    % Computes PSNR per frame
    for k = 1:num_frames
        recon_path = fullfile(output_folder, frame_files(k).name);
        if ~isfile(recon_path)
            warning('Missing frame: %s', recon_path);
            continue;
        end
        recon = double(imread(recon_path));
        mse = mean((orig{k}(:) - recon(:)).^2);
        psnrVals(gi, k) = 10 * log10(MAX_I^2 / mse);
    end
end

% Plotting results
figure; hold on;
colors = {'r','g','b'};
for gi = 1:numel(gopSizes)
    plot(1:num_frames, psnrVals(gi,:), '-o', 'Color', colors{gi}, ...
        'DisplayName', sprintf('GOP = %d', gopSizes(gi)));
end
xlabel('Frame Index');
ylabel('PSNR (dB)');
title('PSNR vs Frame Number (Basic Algorithm)');
legend('Location','best');
grid on;
