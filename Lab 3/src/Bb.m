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

stem(m, dtfscomps), xlabel('log_2(N)'), ylabel('Time cost (s)');
grid on;
