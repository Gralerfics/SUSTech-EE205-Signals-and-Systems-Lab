clear;

%% Load Raw Signals
[y_wav_a, fs_wav_a] = audioread("C_01_01.wav");
[y_wav_b, fs_wav_b] = audioread("C_01_02.wav");
y_wav_a = y_wav_a';
y_wav_b = y_wav_b';

%% Generate Filter
[Pxx, w] = pwelch(repmat(y_wav_a, 1, 10), [], [], 512, fs_wav_a); % Power Spectral Density
b = fir2(30000, w / (fs_wav_a / 2), sqrt(Pxx / max(Pxx))); % Generate coefficients
[h, hw] = freqz(b, 1, 128);

%% Obtain SSN for Signal B
N = length(y_wav_b);
noise = 1 - 2 * rand(1, N + length(b) - 1); % White Noise
ssn = filter(b, 1, noise);
ssn = ssn(length(b) : end);

%% Adjust Signal Density
x = y_wav_b;
ssn = ssn / norm(ssn) * norm(x) * 10 ^ (1 / 4);
disp(20 * log10(norm(x) / norm(ssn))); % Test the value
y = x + ssn;
y = y / norm(y) * norm(x); % normalization

%% Generate Low-pass Filters
fs = fs_wav_b;
[b1, a1] = butter(2, 100 / (fs / 2));
[b2, a2] = butter(2, 200 / (fs / 2));
[b3, a3] = butter(2, 300 / (fs / 2));
[b4, a4] = butter(6, 200 / (fs / 2));

x = abs(x);
y1 = filter(b1, a1, x);
y2 = filter(b2, a2, x);
y3 = filter(b3, a3, x);
y4 = filter(b4, a4, x);

%% Plotting
figure(1);
subplot(3, 1, 1);
plot(linspace(0, length(y_wav_a) / fs_wav_a, length(y_wav_a)), y_wav_a);
xlabel("t"), ylabel("Raw Signal A"), xlim([0, length(y_wav_a) / fs_wav_a]);
legend("x_A(t)");
subplot(3, 1, 2);
semilogy(hw, abs(h), "LineWidth", 1);
xlabel("\omega"), ylabel("Magnitude"), xlim([hw(1), hw(end)]);
legend("H(j\omega)");
subplot(3, 1, 3);
plot(linspace(0, N / fs_wav_b, N), ssn);
xlabel("t"), ylabel("SSN"), xlim([0, N / fs_wav_b]);
legend("SSN");

figure(2);
subplot(2, 1, 1);
plot(linspace(0, length(y_wav_b) / fs_wav_b, length(y_wav_b)), y_wav_b);
xlabel("t"), ylabel("Raw Signal B"), xlim([0, length(y_wav_b) / fs_wav_b]);
legend("x_B(t)");
subplot(2, 1, 2);
plot(linspace(0, length(y) / fs_wav_b, length(y)), y);
xlabel("t"), ylabel("y(t)"), xlim([0, length(y) / fs_wav_b]);
legend("y(t) = x(t) + SSN");

figure(3);
subplot(3, 1, 1);
plot(y1), xlabel("t"), ylabel("Envelope Waveform"), ylim([-0.05, 0.2]);
legend("Order = 2, f_{cut} = 100 Hz");
subplot(3, 1, 2);
plot(y2), xlabel("t"), ylabel("Envelope Waveform"), ylim([-0.05, 0.2]);
legend("Order = 2, f_{cut} = 200 Hz");
subplot(3, 1, 3);
plot(y3), xlabel("t"), ylabel("Envelope Waveform"), ylim([-0.05, 0.2]);
legend("Order = 2, f_{cut} = 300 Hz");

figure(4);
subplot(2, 1, 1);
plot(y2), xlabel("t"), ylabel("Envelope Waveform"), ylim([-0.05, 0.2]);
legend("Order = 2, f_{cut} = 200 Hz");
subplot(2, 1, 2);
plot(y4), xlabel("t"), ylabel("Envelope Waveform"), ylim([-0.05, 0.2]);
legend("Order = 6, f_{cut} = 200 Hz");
