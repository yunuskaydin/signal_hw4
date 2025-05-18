% Watermark an audio
% Input message
message = 'Megastar Tarkan';
bin_msg = reshape(dec2bin(message, 8).'-'0', 1, []);


% Load audio
[audio, fs] = audioread('audio.wav');
audio = audio(:,1);  % Mono
N = length(audio);

% Embed in middle frequencies
dct_audio = dct(audio);
plot(dct_audio);
start_idx = 1000;
for k = 1:length(bin_msg)
    idx = start_idx + k - 1;
    coeff = dct_audio(idx);
    % get rid of the LSB
    coeff = coeff - mod(round(coeff), 2);
    % add the message bit
    coeff = coeff + bin_msg(k);
    dct_audio(idx) = coeff;
end

watermarked_audio = idct(dct_audio);
audiowrite('watermarked_audio.wav', watermarked_audio, fs);