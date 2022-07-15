clear;
x1 = DTS(0 : 9, [ones(1, 5) zeros(1, 5)]);
hg2 = DTS(0 : 4, [0 2 5 4 -1]);
xg = DTS(0 : 4, [2 0 0 0 0]); % Step 1
yga = xg .^ 2;
ygb = xg * hg2; % Step 2
yg1 = yga + ygb; % Step 3
delta = DTS(0 : 4, [1 0 0 0 0]); % Step 4
hg1 = delta .^ 2;
hparallel = hg1 + hg2; % Step 5
yg2 = xg * hparallel; % Step 6
DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "y[n]", "grid", "on"), ...
    { yg1.sInf("y_{g1}[n]", "#01AFEE") }, ...
    struct("xlabel", "n", "ylabel", "y[n]", "grid", "on"), ...
    { yg2.sInf("y_{g2}[n]", "#2E9F79") } ...
);
