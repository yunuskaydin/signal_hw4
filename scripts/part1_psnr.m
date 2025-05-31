% eval_gop_psnr.m

addpath('./functions');

%% Parameters
input_folder   = '../video_data/';
frame_files    = dir(fullfile(input_folder,'*.jpg'));
num_frames     = numel(frame_files);
gopSizes       = [1, 15, 30];
blockH = 8;  blockW = 8;     % your macroblock dimensions
MAX_I  = 255;               % 8-bit pixel max

%% 1) Load originals
orig = cell(1,num_frames);
for k = 1:num_frames
    orig{k} = double(imread(fullfile(input_folder, frame_files(k).name)));
end

%% 2) Preallocate PSNR storage
psnrVals = zeros(numel(gopSizes), num_frames);

%% 3) Loop over GOP sizes
for gi = 1:numel(gopSizes)
    gop = gopSizes(gi);
    binName = sprintf('temp_gop%02d.bin', gop);
    
    %--- Compress with this GOP ---
    fid = fopen(binName,'w');
    prev_mb = [];
    for k = 1:num_frames
        frame    = orig{k};
        mb_cells = frame_to_mb(frame);           % your existing helper
        is_iframe = mod(k-1, gop)==0;
        fwrite(fid, is_iframe, 'uint8');
        
        for i = 1:size(mb_cells,1)
          for j = 1:size(mb_cells,2)
            block = mb_cells{i,j};
            if is_iframe
              [rle,len] = compress_block(block);
            else
              residual = block - prev_mb{i,j};
              [rle,len] = compress_block(residual);
            end
            for ch = 1:3
              fwrite(fid, len(ch),     'int16');
              fwrite(fid, rle{ch},     'int16');
            end
          end
        end
        prev_mb = mb_cells;
    end
    fclose(fid);
    
    %--- Decompress and compute PSNR per frame ---
    fid = fopen(binName,'r');
    prev_mb = [];
    for k = 1:num_frames
        % Read I-frame flag
        is_iframe = fread(fid,1,'uint8');
        
        % Prepare empty reconstruction
        [H,W,~] = size(orig{k});
        recFrame = zeros(H,W,3);
        
        % Decode each macroblock
        for i = 1:H/blockH
          for j = 1:W/blockW
            % Temporary holder for this MB
            recon_mb = zeros(blockH, blockW, 3);
            for ch = 1:3
              L = fread(fid,1,'int16');         % run-length count
              data = fread(fid, 2*L, 'int16');  % [val1 run1 val2 run2 …]
              % RLE → vector
              v = [];
              for p = 1:2:numel(data)
                v = [v; repmat(data(p), data(p+1),1)]; 
              end
              % reshape & add back if P-frame
              v = v(:);  % ensure it's a column
                if length(v) < 64
                    v = [v; zeros(64 - length(v), 1)];  % pad with zeros
                elseif length(v) > 64
                    v = v(1:64);  % trim
                end
                block = reshape(v, [blockH, blockW]);
              if is_iframe
                recon_mb(:,:,ch) = block;
              else
                recon_mb(:,:,ch) = block + prev_mb{i,j}(:,:,ch);
              end
            end
            % place into recFrame
            row = (i-1)*blockH + (1:blockH);
            col = (j-1)*blockW + (1:blockW);
            recFrame(row,col,:) = recon_mb;
          end
        end
        
        % store for next P-frame
        prev_mb = mat2cell(recFrame, repmat(blockH,H/blockH,1), repmat(blockW,W/blockW,1), 3);
        
        % Compute MSE & PSNR
        err = (orig{k} - recFrame).^2;
        mse = mean(err(:));
        psnrVals(gi,k) = 10*log10( MAX_I^2 / mse );
    end
    fclose(fid);
end

%% 4) Plot all three PSNR curves
figure; hold on;
cols = {'r','g','b'};
for gi = 1:numel(gopSizes)
  plot(1:num_frames, psnrVals(gi,:), '-o', 'Color', cols{gi}, ...
       'DisplayName', sprintf('GOP = %d', gopSizes(gi)));
end
xlabel('Frame index');
ylabel('PSNR (dB)');
title('PSNR vs Frame Number for GOP = 1,15,30');
legend('Location','best');
grid on;
