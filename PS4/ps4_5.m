% Watermark an image

% Prepare the message
message = 'Otters are cute';
bin_msg = reshape(dec2bin(message, 8).'-'0', 1, []); % length 120


% load image
img = imread("image.bmp"); % (360, 480, 3)
img = double(img);

img_mbs = frame_to_mb(img); % get the macroblock representation
[height, width] = size(img_mbs); % (45, 60)

% hide the message in first two rows
for i = 1:2
    for j = 1:width
        current_macroblock = img_mbs{i, j}; % (8, 8, 3)
        r_channel = current_macroblock(:, :, 1); % use red channel

        r_channel_dct = dct2(r_channel - 128); % take the DCT

        message_idx = (i - 1) * width + j;
        msg_bit = bin_msg(message_idx); % message bit

        r_channel_dct(2, 2) = 100*msg_bit; % hide the message in coeffs

        % put everything back
        r_channel = idct2(r_channel_dct) + 128; % take inverse DCT
        current_macroblock(:, :, 1) = r_channel; 
        img_mbs{i, j} = current_macroblock;
    end
end

% get the final image
watermarked_img = mb_to_frame(img_mbs);

% imshow(uint8(watermarked_img));

% save it
imwrite(uint8(watermarked_img), "watermarked_img.bmp", "bmp");