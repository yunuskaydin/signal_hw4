% parameters
fs = 2000;
tt = 0:1/fs:2-1/fs;

% define the signal
f1 = 200; % Hz
f2 = 300; % Hz
w = cos(2*pi*f1*tt) + cos(2*pi*f2*tt);

% Let's investigate how the results of the FFT and DCT look
hold on;
fft_results = fft(w);
subplot(3,1,1);
plot(abs(fft_results));
shifted = fftshift(fft_results);
subplot(3,1,2);
plot(abs(shifted));
subplot(3,1,3);
plot(dct(w));
hold off;

