clear;
N = 1000;
alpha = 0.5;
delta = DTS(0 : 1000, [1 zeros(1, 1000)]);
he = delta.filter([1 zeros(1, N - 1) alpha], [1]);
d = DTS(0 : 4000, [1 zeros(1, 4000)]);
her = d.filter([1], [1 zeros(1, N - 1) alpha]);
hoa = he * her;
DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "h_{oa}[n]", "grid", "on"), ...
    { hoa.sInf("h_{oa}[n]") } ...
);
