clear;
load("lineup.mat");
Y = DTS(0 : (length(y) - 1), y');
Ryy = Y * Y.stretch(-1);
figure(1);
DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "R_{yy}[n]", "grid", "on"), ...
    { Ryy.sInf("R_{yy}[n]", "", "", "plot") } ...
);

Y = DTS(0 : (length(y2) - 1), y2');
Ryy = Y * Y.stretch(-1);
figure(2);
DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "R_{yy}[n]", "grid", "on", "xlim", [-4000 4000]), ...
    { Ryy.sInf("R_{yy}[n]", "", "", "plot") } ...
);

Y = DTS(0 : (length(y3) - 1), y3');
% N = 751;
% alpha = 0.599;
% Y = Y.filter([1], [1 zeros(1, N - 1) alpha]);
Ryy = Y * Y.stretch(-1);
figure(3);
DTS.Figures("v", ...
    struct("xlabel", "n", "ylabel", "R_{yy}[n]", "grid", "on", "xlim", [-4000 4000]), ...
    { Ryy.sInf("R_{yy}[n]", "", "", "plot") } ...
);
