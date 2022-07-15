clear;
x1 = DTS(0 : 9, [ones(1, 5) zeros(1, 5)]);
hf2 = DTS(0 : 4, [1 -1 3 1 0]);
np1 = DTS(0 : 9, 1 : 10); % (n + 1)
w = np1 .* x1; % Step 1
yf1 = w * hf2; % Step 2
delta = DTS(0 : 4, [1 0 0 0 0]); % Step 3
hf1 = np1.cut(0 : 4) .* delta;
hseries = hf1 * hf2; % Step 4
yf2 = x1 * hseries; % Step 5
DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "y[n]", "grid", "on"), ...
    { yf1.sInf("y_{f1}[n]", "#01AFEE") }, ...
    struct("xlabel", "n", "ylabel", "y[n]", "grid", "on"), ...
    { yf2.sInf("y_{f2}[n]", "#2E9F79") } ...
);