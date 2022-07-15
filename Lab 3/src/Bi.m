clear;

L = 1; S = 1000; R = 200000;
C = []; F = [];
for N = L : S : R
    disp(N);
    x = 0.9 .^ DTS.Identity({0, N - 1});
    h = 0.5 .^ DTS.Identity({0, N - 1});
    T1 = 2; T2 = 2;
    tic; for I = 1 : T1; DTS.Pconv(x, h); end
    C = [C, toc / T1];
    tic; for I = 1 : T2; DTS.Pconvfft(x, h); end
    F = [F, toc / T2];
end

figure(1);
hold on, grid on;
stem(L : S : R, C * 1000);
stem(L : S : R, F * 1000);
xlim([L, R]);
xlabel("N"), ylabel("Time cost (ms)");
legend(["Method conv", "Method fft & ifft"])

figure(2);
stem(L : S : R, C ./ F);
xlim([L, R]);
xlabel("N"), ylabel("Ratio \frac{c}{f}");
