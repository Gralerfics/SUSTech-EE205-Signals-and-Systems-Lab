%% Calculating
L_corDt = 100;
N = L_corDt - t0_s + 1;
hmap_res = gpuArray(zeros(N + 1, d_idxSet(end) + 1));
t_Set = (0 : N) * duration / t0_s;

for T0 = 1 : N
    hmap_tmp = gpuArray(zeros(c_idxSet(end) + 1, d_idxSet(end) + 1));
    for I = 0 : (t0_s - 1)
        hmap_tmp(:, :) = hmap_tmp(:, :) + [squeeze(corDt(T0 + I, :, :)), zeros(c_idxSet(end), 1); zeros(1, d_idxSet(end)), 0];
    end
    hmap_tmp = abs(hmap_tmp);
    hmap_tmp_max = max(max(hmap_tmp));
    [R_tmp_idx, D_tmp_idx] = find(hmap_tmp == hmap_tmp_max);
    hmap_tmp = (hmap_tmp / hmap_tmp_max) .^ order_rmv;
    hmap_res(T0, :) = hmap_tmp(R_tmp_idx, :);
    cd_res(T0, 1) = r_Set(R_tmp_idx) + 6;
    cd_res(T0, 2) = d_Set(D_tmp_idx) + 1;
end

%% Plotting
tfHeatmapFigure = figure(3);
set(gcf, "Position", [0 0 600 800]);
[meshgrid_Doppler, meshgrid_Time] = meshgrid(d_Set, t_Set);
surf(meshgrid_Doppler, meshgrid_Time, hmap_res);
view(0, 90);
colorbar;
xlim([d_Set(1), d_Set(end)]), xlabel("Doppler Frequency (Hz)");
ylim([t_Set(1), t_Set(end)]), ylabel("Time (s)");
y_tickSet = linspace(0, (dataIndex(end) - 1) * duration, dataIndex(end));
set(gca, 'YTick', y_tickSet);
set(gca, 'YTicklabel', num2str(y_tickSet'));
title("Time-Doppler Spectrum");
print(tfHeatmapFigure, "output/tfHeatmapFigure_r300.png", "-dpng", "-r300");
