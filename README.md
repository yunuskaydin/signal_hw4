# Simplified Video Compression with DCT and Predictive Coding Intro to Digital Signal Processing Project

A MATLAB implementation of video compression with basic and improved (motion estimation) algorithms.

## Project Structure
```
├── scripts/
│   ├── functions/
│   │   ├── compress_block.m
│   │   ├── decompress_block.m
│   │   ├── frame_to_mb.m
│   │   ├── inverse_zigzag.m
│   │   └── mb_to_frame.m
│   │   └── motion_estimate.m
│   │   └── QMatrix.m
│   │   └── run_length_decode.m
│   │   └── run_length_encode.m
│   │   └── zigzag_scan.m
│   ├── compress.m
│   ├── decompress.m
│   ├── improved_compress.m
│   ├── improved_decompress.m
│   ├── part1_compress_ratio_plot.m
│   ├── part2_psnr.m
│   ├── part2_compress_ratio_plot.m
│   └── part2_psnr.m
├── video_data/
├── README.md
├── report.pdf
```

## Running Order

1. Basic Implementation:
```matlab
compress                    % Compress frames
decompress                 % Decompress frames
part1_compress_ratio_plot  % Plot compression ratios
part1_psnr                % Calculate and plot PSNR
```

2. Improved Implementation:
```matlab
improved_compress         % Compress with motion estimation
improved_decompress      % Decompress with motion estimation
part2_compress_ratio_plot % Plot compression ratios
part2_psnr               % Calculate and plot PSNR
```

## Requirements

- MATLAB R2019b or later
- Image Processing Toolbox

