clear;

%% (b)
tau = 0.01;
T = 10;
N = T / tau;

t = linspace(0, T - tau, N);
w = -(pi / tau) + (0 : N - 1) * (2 * pi / (N * tau)); % Even N
y = exp(-2 * abs(t - 5));
Xa = 1 ./ (2 + 1j .* w) + 1 ./ (2 - 1j .* w);
Ya = exp(-1j * 5 * w) .* Xa;

figure("Name", "b");
subplot(2, 1, 1), plot(t, y, "LineWidth", 1);
xlabel("t"), ylabel("y(t)");
legend("y(t) = x(t - 5) = e^{-2|t - 5|}");
subplot(2, 1, 2), plot(w, abs(Ya), "r", "LineWidth", 1);
xlabel("\omega"), ylabel("|Y(j\omega)_{Analytic}|"), xlim([w(1), w(end)]);
legend("|Y(j\omega)_{Analytic}|");

%% (c)
Y = fftshift(tau * fft(y));

figure("Name", "c");
plot(w, abs(Y), "r", "LineWidth", 1);
xlabel("\omega"), ylabel("|Y(j\omega)_{FFT}|"), xlim([w(1), w(end)]);
legend("|Y(j\omega)|_{FFT}");

%% (e)
X = exp(1j * 5 * w) .* Y;

figure("Name", "e");
plot(w, abs(X), "b", "LineWidth", 1);
xlabel("\omega"), ylabel("|X(j\omega)|_{FFT}"), xlim([w(1), w(end)]);
legend("|X(j\omega)|_{FFT}");

%% (f) - 1
figure("Name", "f1");
subplot(2, 2, 1), plot(w, abs(X), "LineWidth", 1);
xlabel("\omega"), ylabel("|X(j\omega)_{FFT}|"), xlim([w(1), w(end)]);
legend("|X(j\omega)|");
subplot(2, 2, 2), plot(w, angle(X), "r", "LineWidth", 1);
xlabel("\omega"), ylabel("∠X(j\omega)_{FFT}"), xlim([w(1), w(end)]);
legend("∠X(j\omega)");
subplot(2, 2, 3), plot(w, abs(Xa), "LineWidth", 1);
xlabel("\omega"), ylabel("|X(j\omega)_{Analytic}|"), xlim([w(1), w(end)]);
legend("|X(j\omega)_{Analytic}|");
subplot(2, 2, 4), plot(w, angle(Xa), "r", "LineWidth", 1);
xlabel("\omega"), ylabel("∠X(j\omega)_{Analytic}"), xlim([w(1), w(end)]);
legend("∠X(j\omega)_{Analytic}");

%% (f) - 2
figure("Name", "f2");
subplot(1, 2, 1), semilogy(w, abs(X), "LineWidth", 1);
xlabel("\omega"), ylabel("|X(j\omega)_{FFT}|"), xlim([w(1), w(end)]);
legend("|X(j\omega)|");
subplot(1, 2, 2), semilogy(w, abs(Xa), "LineWidth", 1);
xlabel("\omega"), ylabel("|X(j\omega)_{Analytic}|"), xlim([w(1), w(end)]);
legend("|X(j\omega)_{Analytic}|");

%% (g)
figure("Name", "g");
subplot(2, 2, 1), plot(w, abs(X), "LineWidth", 1);
xlabel("\omega"), ylabel("|X(j\omega)|"), xlim([w(1), w(end)]);
legend("|X(j\omega)|");
subplot(2, 2, 2), plot(w, angle(X), "r", "LineWidth", 1);
xlabel("\omega"), ylabel("∠X(j\omega)"), xlim([w(1), w(end)]);
legend("∠X(j\omega)");
subplot(2, 2, 3), plot(w, abs(Y), "LineWidth", 1);
xlabel("\omega"), ylabel("|Y(j\omega)|"), xlim([w(1), w(end)]);
legend("|Y(j\omega)|");
subplot(2, 2, 4), plot(w, angle(Y), "r", "LineWidth", 1);
xlabel("\omega"), ylabel("∠Y(j\omega)"), xlim([w(1), w(end)]);
legend("∠Y(j\omega)");
