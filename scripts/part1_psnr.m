% plot_psnr_gops_debug.m
% ——————————————————————————————————————————————————————————
% Decompress GOP=1,15,30 bitstreams, clamp/zero‐floor PSNR, dump debug images, plot PSNR

%% 0) PARAMETERS
input_folder = '../video_data';               % original .jpg frames
output_dir   = '../outputs';    % where your result_gopXX.bin live
frame_files  = dir(fullfile(input_folder,'*.jpg'));
num_frames   = numel(frame_files);

gopSizes = [1, 15, 30];
numGops   = numel(gopSizes);
psnrVals  = zeros(numGops, num_frames);

% Frame & macroblock dims
H      = 360;  W      = 480;  C = 3;
blockH = 8;    blockW = 8;
MB_rows = H/blockH;
MB_cols = W/blockW;
MAX_I   = 255;  

% Make a debug folder
if ~exist('debug_frames','dir')
    mkdir('debug_frames');
end

%% 1) LOAD ORIGINALS INTO 4‐D ARRAY
orig = zeros(H, W, C, num_frames);
for k = 1:num_frames
    orig(:,:,:,k) = double(imread(fullfile(input_folder, frame_files(k).name)));
end

%% 2) DECOMPRESS & COMPUTE PSNR
for gi = 1:numGops
    gop = gopSizes(gi);
    fprintf('--- Processing GOP = %02d ---\n', gop);
    
    % open corresponding bitstream
    fname = sprintf('result_gop%02d.bin', gop);
    fid   = fopen(fullfile(output_dir, fname), 'r');
    if fid < 0
        error('Could not open %s', fname);
    end
    
    % numeric buffer for previous‐frame MBs: [h,w,ch,row,col]
    prev_mb = zeros(blockH, blockW, C, MB_rows, MB_cols);
    
    for k = 1:num_frames
        % read I/P flag
        is_iframe = fread(fid, 1, 'uint8');
        recFrame  = zeros(H, W, C);
        
        % decode every macroblock
        for i = 1:MB_rows
            for j = 1:MB_cols
                recon_mb = zeros(blockH, blockW, C);
                
                for ch = 1:C
                    % read run‐length count
                    L = fread(fid, 1, 'int16');
                    if L > 0
                        data = fread(fid, 2*L, 'int16');
                    else
                        data = [];
                    end
                    
                    % fast RLE → fixed‐length vector v
                    N   = blockH * blockW;
                    v   = zeros(N,1);
                    pos = 1;
                    for p = 1:2:numel(data)
                        val = data(p);
                        run = data(p+1);
                        take = min(run, N-pos+1);
                        if take>0
                            v(pos:pos+take-1) = val; 
                            pos = pos + take;
                        end
                        if pos > N
                            break;
                        end
                    end
                    
                    block = reshape(v, blockH, blockW);
                    
                    % intra vs. inter
                    if is_iframe
                        recon_mb(:,:,ch) = block;
                    else
                        recon_mb(:,:,ch) = block + prev_mb(:,:,ch,i,j);
                    end
                end
                
                % write it back into the full frame
                rows = (i-1)*blockH + (1:blockH);
                cols = (j-1)*blockW + (1:blockW);
                recFrame(rows,cols,:) = recon_mb;
                
                % save for next frame’s prediction
                prev_mb(:,:,:,i,j) = recon_mb;
            end
        end
        
        % 2a) clamp pixel range
        recFrame = min(max(recFrame, 0), 255);
        
        % 2b) compute & floor PSNR
        err  = (orig(:,:,:,k) - recFrame).^2;
        mse  = mean(err(:));
        psnr = 10*log10( MAX_I^2 / mse );
        psnrVals(gi,k) = max(psnr, 0);
        
        % 2c) dump first 3 frames for visual debug
        if k <= 3
            dbgname = sprintf('debug_frames/gop%02d_frame%03d.png', gop, k);
            imwrite(uint8(recFrame), dbgname);
        end
    end
    
    fclose(fid);
end

%% 3) PLOT PSNR CURVES
figure; hold on;
cols = {'r','g','b'};
for gi = 1:numGops
    plot(1:num_frames, psnrVals(gi,:), '-o', ...
         'Color', cols{gi}, ...
         'DisplayName', sprintf('GOP = %d', gopSizes(gi)));
end
xlabel('Frame Number');
ylabel('PSNR (dB)');
title('PSNR vs Frame Number for GOP = 1, 15, 30 (clamped & debug)');
legend('Location','best');
grid on;
