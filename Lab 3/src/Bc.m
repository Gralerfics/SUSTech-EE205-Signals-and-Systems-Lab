clear;

m = [3, 5, 6, 7, 8];
dtfscomps = [];
T = 100;
for N = 2 .^ m
    x = 0.9 .^ DTS.Identity({0, N - 1});
    tic;
    for I = 1 : T; x.dtfs; end
    dtfscomps = [dtfscomps, toc / T];
end

fftcomps = [];
T = 100;
for N = 2 .^ m
    x = 0.9 .^ DTS.Identity({0, N - 1});
    tic;
    for I = 1 : T; x.fft; end
    fftcomps = [fftcomps, toc / T];
end

figure(1);
stem(m, fftcomps), xlabel('log_2(N)'), ylabel('Time cost (s)');
grid on;

figure(2);
hold on, grid on;
stem(m, dtfscomps ./ fftcomps);
plot(3 : 0.1 : 8, 2 .^ (3 : 0.1 : 8) ./ (3 : 0.1 : 8));
xlabel('log_2(N)'), ylabel('Ratio (dtfscomps / fftcomps)');
legend("Ratio", "N / log_2N")
