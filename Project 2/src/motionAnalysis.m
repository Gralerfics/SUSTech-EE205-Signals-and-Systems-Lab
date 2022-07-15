%% Calculating
L = 247;
T = duration / t0_s;
REP = 10000;

c_t = cd_res(:, 1)';
d_t = cd_res(:, 2)';
x_t = c_t / 2 .* (c_t + 2 * L) ./ (c_t + L);

for K = 1 : REP
    b_t = x_t ./ sqrt(L * L + x_t);
    v_t = - lambda .* d_t ./ (sqrt((b_t + 1) ./ 2) .* 2);
    
    X_t = (v_t + circshift(v_t, 1)) / 2 * T;
    x_t(1) = 0;
    for J = 2 : length(v_t)
        x_t(J) = sum(X_t(2 : J));
    end
    x_t = x_t + 12;
end

%% Plotting - Remember to reset cd_res before timeFreqFigure!
vtFigure = figure(4);
plot(t_Set(1 : end - 1), x_t, "LineWidth", 1), hold on;
plot(t_Set(1 : end - 1), v_t, "LineWidth", 1);
grid on;
xlabel("Time (s)"), ylabel("Distance (m) & Velocity (m/s)");
xlim([t_Set(1) t_Set(end - 1)]), ylim([-6, 16]);
legend("x(t)", "v(t)");
print(vtFigure, "output/vtFigure_r300.png", "-dpng", "-r300");
