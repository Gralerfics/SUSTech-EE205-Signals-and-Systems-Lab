clear;
x1 = DTS(0 : 9, [ones(1, 5) zeros(1, 5)]);
h1 = DTS(0 : 4, [1 -1 3 1 0]);
h2 = DTS(0 : 4, [0 2 5 4 -1]);
w = x1 * h1;
yd1 = w * h2;
hs = h1 * h2;
yd2 = x1 * hs;
DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "w[n]", "grid", "on"), ...
    { w.sInf("w[n] = x_1[n] * h_1[n]", "#01AFEE") }, ...
    struct("xlabel", "n", "ylabel", "y_{d1}[n]", "grid", "on"), ...
    { yd1.sInf("y_{d1}[n] = w[n] * h_2[n]", "#2E9F79") }, ...
    struct("xlabel", "n", "ylabel", "h_{series}[n]", "grid", "on"), ...
    { hs.sInf("h_{series}[n] = h_1[n] * h_2[n]", "#01AFEE") }, ...
    struct("xlabel", "n", "ylabel", "y_{d2}[n]", "grid", "on"), ...
    { yd2.sInf("y_{d2}[n] = x_1[n] * h_{series}[n]", "#2E9F79") } ...
);
