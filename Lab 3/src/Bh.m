clear;

N = 80;
T = 10000;
x = 0.9 .^ DTS.Identity({0, N - 1});
h = 0.5 .^ DTS.Identity({0, N - 1});
tic;
for I = 1 : T; y = DTS.Pconvfft(x, h); end
f80f = toc / T;

DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "y[n]", "xlim", [0, N - 1], "grid", "on"), ...
    { y.sInf("y[n]", "b") } ...
);
