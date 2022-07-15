%% Passive Radar Simulation
% clear;
addpath("data");
coder.gpu.kernelfun;

tfMap = true;
heatMap = true;
resetCorDt = true;
resaveCorDt = true;
useBandLow = true;

dataIndexSet = 1 : 20;      % 数据集
order_lpf = 20;             % 低通滤波器阶数
order_rmv = 3;              % 归一化后降噪的幂

if useBandLow
    f_ddc = -3e6;           % 中心频率
    f_w = 9e6;              % 带宽
else
    f_ddc = 9.5e6;
    f_w = 2e6;
end

c_Set = 0 : 6;              % 时延采样间隔点
d_Set = -40 : 2 : 40;       % 频移采样间隔点值
c_idxSet = 1 : length(c_Set) - 1; % 时延采样左值点索引
d_idxSet = 1 : length(d_Set) - 1; % 频移采样左值点索引

t0_s = 5;                   % 时间-频移热图单个数据集内时间轴上的时间采样个数

if resetCorDt
    corDt = gpuArray(zeros(t0_s * dataIndexSet(end), c_idxSet(end), d_idxSet(end)));
end

for dataIndex = dataIndexSet
    % 读取当前数据子集
    load("data_" + num2str(dataIndex) + ".mat");
    disp("Data_" + num2str(dataIndex));

    % 基本量
    dt = 1 / f_s;     % 原信号采样间隔
    lambda = 3e8 / f_c;     % 中心波长

    r_Set = c_Set / f_s * 3e8;  % 路程差
    c_mSet = c_Set(1 : end - 1) / f_s;               % 时延采样左值点
    d_mSet = d_Set(1 : end - 1);                     % 频移采样左值点 

    t0_vOffset = cur_time;
    t0_idxOffset = (dataIndex - 1) * t0_s;

    t0_vSet = linspace(0, duration, t0_s + 1);
    t0_vSet = t0_vSet(1 : end - 1) + t0_vOffset;     % 时间-频移热图的绝对时间采样点
    t0_idxSet = (1 : t0_s) + t0_idxOffset;           % 时间-频移热图的绝对时间采样点索引
    
    l_ref = length(seq_ref);    % 参考信号采样点个数
    l_sur = length(seq_sur);    % 监视信号采样点个数
    t_ref = linspace(0, duration - dt, l_ref);  % 参考信号时域向量
    t_sur = linspace(0, duration - dt, l_sur);  % 监视信号时域向量

    timeToPoint = @(T) floor(T / dt + 1);

    % 数字下变频
    disp("  DDC.");
    fac_ref = exp(-1j * 2 * pi * f_ddc * t_ref);
    fac_sur = exp(-1j * 2 * pi * f_ddc * t_sur);
    ref_ddc = seq_ref .* fac_ref;
    sur_ddc = seq_sur .* fac_sur;

    % 低通滤波
    disp("  LPF.");
    [b_lpf, a_lpf] = butter(order_lpf, f_w / (f_s / 2));
    % freqz(b_lpf, a_lpf, 200, 'whole');
    ref_lpf = filter(b_lpf, a_lpf, ref_ddc);
    sur_lpf = filter(b_lpf, a_lpf, sur_ddc);

    ref = gpuArray([ref_lpf, zeros(1, c_Set(end) + 1)]);
    sur = gpuArray([sur_lpf, zeros(1, c_Set(end) + 1)]);

    % 时间轴分段模糊函数值表
    if heatMap
        disp("  AMBIGUITY.");
        hmap = gpuArray(zeros(c_idxSet(end) + 1, d_idxSet(end) + 1));
    
        for t0_idx = t0_idxSet                   % 绝对时间轴采样点索引
            t0 = t0_vSet(t0_idx - t0_idxOffset); % 绝对时间轴采样点
            disp("    t0 = " + num2str(t0));
            for c_idx = c_idxSet                 % 时延采样点索引
                disp("      c_idx = " + num2str(c_idx));
                for d_idx = d_idxSet             % 频移采样点索引
                    c = c_mSet(c_idx);
                    d = d_mSet(d_idx);
                    % disp("      c_idx = " + num2str(c_idx) + ", d_idx = " + num2str(d_idx));
                    
                    T = duration / t0_s;
                    N1 = timeToPoint(t0 - t0_vOffset);
                    N2 = timeToPoint(t0 - t0_vOffset + T);
                    C = floor(timeToPoint(c)) - 1;
                    fac = gpuArray(exp(-1j * 2 * pi * d * linspace(t0, t0 + T, N2 - N1 + 1)));
                    y_ref = gpuArray(ref(N1 : N2));
                    y_sur = gpuArray(sur((N1 : N2) + C));
                    y = y_sur .* conj(y_ref) .* fac;

                    % 积分
                    y = (y + circshift(y, 1)) / 2;
                    y = y(2 : end);
                    corDt(t0_idx, c_idx, d_idx) = sum(y) * dt;
    
                    % 当前数据子集下的完整模糊函数值表
                    hmap(c_idx, d_idx) = hmap(c_idx, d_idx) + corDt(t0_idx, c_idx, d_idx);
                end
            end
        end
    end

    % 绘图与持久化存储
    if tfMap
        spectrumFigure = figure(1);
        set(gcf, 'position', [0, 0, 1000, 900]);
        subplot(6, 2, 1);
        plotTimeSpectrum_ms_Re(seq_ref, f_s, "Reference Signal (Raw)");
        subplot(6, 2, 2);
        plotFrequencySpectrum_MHz_dB(seq_ref, f_s, "Frequency Spectrum (Raw)");
        subplot(6, 2, 7);
        plotTimeSpectrum_ms_Re(seq_sur, f_s, "Surveillance Signal (Raw)");
        subplot(6, 2, 8);
        plotFrequencySpectrum_MHz_dB(seq_sur, f_s, "Frequency Spectrum (Raw)");
        subplot(6, 2, 3);
        plotTimeSpectrum_ms_Re(ref_ddc, f_s, "Reference Signal (After DDC)");
        subplot(6, 2, 4);
        plotFrequencySpectrum_MHz_dB(ref_ddc, f_s, "Frequency Spectrum (After DDC)");
        subplot(6, 2, 9);
        plotTimeSpectrum_ms_Re(sur_ddc, f_s, "Surveillance Signal (After DDC)");
        subplot(6, 2, 10);
        plotFrequencySpectrum_MHz_dB(sur_ddc, f_s, "Frequency Spectrum (After DDC)");
        subplot(6, 2, 5);
        plotTimeSpectrum_ms_Re(ref_lpf, f_s, "Reference Signal (After LPF)");
        subplot(6, 2, 6);
        plotFrequencySpectrum_MHz_dB(ref_lpf, f_s, "Frequency Spectrum (After LPF)");
        subplot(6, 2, 11);
        plotTimeSpectrum_ms_Re(sur_lpf, f_s, "Surveillance Signal (After LPF)");
        subplot(6, 2, 12);
        plotFrequencySpectrum_MHz_dB(sur_lpf, f_s, "Frequency Spectrum (After LPF)");
        print(spectrumFigure, "output/SpectrumFigure_Data_" + num2str(dataIndex) + "_r300.png", "-dpng", "-r300");
    end

    if heatMap
        save("rec/hmap_from_" + num2str(cur_time) + "s.mat", "hmap");       % 持久化存储 hmap, 便于修正结果图
        heatmapFigure = figure(2);
        [meshgrid_Doppler, meshgrid_Range] = meshgrid(d_Set, r_Set);
        hmap = abs(hmap);
        hmap_max = max(max(hmap));
        surf(meshgrid_Doppler, meshgrid_Range, (hmap / hmap_max) .^ order_rmv);
        view(0, 90);
        colorbar;
        xlim([d_Set(1), d_Set(end)]), xlabel("Doppler Frequency (Hz)");
        ylim([r_Set(1), r_Set(end)]), ylabel("Range (m)");
        set(gca, 'YTick', r_Set);
        set(gca, 'YTicklabel', num2str(r_Set'));
        [R_idx, D_idx] = find(hmap == hmap_max);
        R = r_Set(R_idx);
        D = d_Set(D_idx);
        title("Range-Doppler Spectrum [ " + num2str(t0_vSet(1)) + "s: " + num2str(R) + "m, " + num2str(D) + "Hz ]");
        print(heatmapFigure, "output/HeatmapFigure_Data_" + num2str(dataIndex) + "_r300.png", "-dpng", "-r300");
    end
end

if resaveCorDt
    save("rec/corDt.mat", "corDt");
end

%% Functions
function plotTimeSpectrum_ms_Re(s, fs, tit)
    l_s = length(s);
    t_s = l_s / fs;
    p_t = linspace(0, t_s, l_s) * 1e3;
    plot(p_t, real(s)), xlim([0, 0.01] * 1e3);
    title(tit);
    xlabel("Time (ms)"), ylabel("Re(Waveform)");
end

function plotFrequencySpectrum_MHz_dB(s, fs, tit)
    l_s = length(s);
    t_s = l_s / fs;
    f_bound = (l_s - 1) / t_s / 2;
    p_f = linspace(-f_bound, f_bound, l_s) / 1e6;
    p_m = 20 * log10(abs(fftshift(fft(s))));
    plot(p_f, p_m), xlim([-f_bound, f_bound] / 1e6), ylim([-70, 30]);
    title(tit);
    xlabel("Frequency (MHz)"), ylabel("Magnitude (dB)");
end
