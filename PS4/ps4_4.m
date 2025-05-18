% Some analysis of the data
% Load audio
[audio1, fs] = audioread('watermarked_audio.wav');
audio1 = audio1(:,1);  % Mono
[audio2, fs] = audioread('audio.wav');
audio2 = audio2(:,1);  % Mono

% Plot dct difference
plot(dct(audio2) - dct(audio1));
xlim([1000 1120]);

% Plot waveform difference
plot(audio2 - audio1);

% Calculate PSNR (based on Mean Squared Error)
diff = audio2 - audio1;
PSNR = 20*log10(sum((diff .* diff))/length(audio));
