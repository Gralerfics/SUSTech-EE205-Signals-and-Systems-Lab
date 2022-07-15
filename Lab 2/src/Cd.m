clear;
N = 1000;
alpha = 0.5;
load("lineup.mat");
s = DTS(0 : (length(y) - 1), y');
z = s.filter([1], [1 zeros(1, N - 1) alpha]);
sound(z.value, 8192);
DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "z[n]", "grid", "on"), ...
    { z.sInf("z[n]", "", "", "plot") } ...
);
