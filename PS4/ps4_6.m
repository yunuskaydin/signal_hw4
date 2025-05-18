% Watermark an image (extraction)

% load image
img = imread("watermarked_img.bmp"); % (360, 480, 3)
img = double(img);

img_mbs = frame_to_mb(img); % get the macroblock representation
[height, width] = size(img_mbs); % (45, 60)

% extract the message from first two rows
extracted_bits = zeros(1, 120); % we know message length is 120
for i = 1:2
    for j = 1:width
        current_macroblock = img_mbs{i, j}; % (8, 8, 3)
        r_channel = current_macroblock(:, :, 1); % use red channel

        r_channel_dct = dct2(r_channel-128); % take the DCT

        message_idx = (i - 1) * width + j;
        msg_bit = r_channel_dct(2, 2) > 90; % get the message in coeffs
        extracted_bits(message_idx) = msg_bit;
    end
end

% get the final message
watermarked_img = mb_to_frame(img_mbs);

extracted_chars = char(bin2dec(reshape(char(extracted_bits + '0'), 8, []).'))';
disp(['Extracted Message: ', extracted_chars]);;