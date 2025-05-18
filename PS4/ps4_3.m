% Extract the watermark

% Load audio
[audio, fs] = audioread('watermarked_audio.wav');
audio = audio(:,1);  % Mono
N = length(audio);

% Need to know the message length and position
% for this case
message_length = 120;
start_idx = 1000;
extracted_bits = zeros(1, message_length);

dct_audio = dct(audio);
for k = 1:message_length
    idx = start_idx + k - 1;
    coeff = round(dct_audio(idx));
    extracted_bits(k) = mod(coeff, 2);
end

extracted_chars = char(bin2dec(reshape(char(extracted_bits + '0'), 8, []).'))';
disp(['Extracted Message: ', extracted_chars]);