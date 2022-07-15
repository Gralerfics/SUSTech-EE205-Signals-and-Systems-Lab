clear;

%% (a)
load("ctftmod.mat");
z = [dash, dash, dot, dot];

figure("Name", "a");
plot(t, z), xlabel("t"), ylabel("z(t)");
legend("z(t) constructed from '--..'");
grid on;

%% (b)
figure("Name", "b");
freqs(bf, af);

%% (c)
ydash = lsim(bf, af, dash, t(1 : length(dash)))';
ydot = lsim(bf, af, dot, t(1 : length(dot)))';

figure("Name", "c");
subplot(2, 1, 1), plot(t(1 : length(dash)), dash, t(1 : length(ydash)), ydash);
xlabel("t"), ylabel("dash"), legend("dash", "ydash");
subplot(2, 1, 2), plot(t(1 : length(dot)), dot, t(1 : length(ydot)), ydot);
xlabel("t"), ylabel("dot"), legend("dot", "ydot");

%% (d)
y = dash .* cos(2 * pi * f1 * t(1 : length(dash)));
yo = lsim(bf, af, y, t(1 : length(y)));

figure("Name", "d");
subplot(2, 1, 1), plot(t(1 : length(y)), y);
xlabel("t"), ylabel("y(t)"), legend("y(t)");
subplot(2, 1, 2), plot(t(1 : length(yo)), yo);
xlabel("t"), ylabel("y_o(t)"), legend("y_o(t)");

%% (f)
x1 = x .* cos(2 * pi * f1 * t);
m1 = 2 * lsim(bf, af, x1, t);

figure("Name", "f");
plot(t, m1), xlabel("t"), ylabel("m_1(t)");
legend("m_1(t)");

%% (g) - 1
x2 = x .* sin(2 * pi * f2 * t);
m2 = 2 * lsim(bf, af, x2, t);

figure("Name", "g1");
plot(t, m2), xlabel("t"), ylabel("m_2(t)");
legend("m_2(t)");

%% (g) - 2
x3 = x .* sin(2 * pi * f1 * t);
m3 = 2 * lsim(bf, af, x3, t);

figure("Name", "g2");
plot(t, m3), xlabel("t"), ylabel("m_3(t)");
legend("m_3(t)");
