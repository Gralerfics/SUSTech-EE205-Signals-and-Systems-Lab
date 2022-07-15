clear;

a1 = [1, -0.8]; b1 = [1];
a2 = [1, 0.8]; b2 = [1];
w_0 = 2 * pi / 20;
a_x = DTS([0, 3 / 4, zeros(1, 7), -1 / 2, 0, - 1 / 2, zeros(1, 7), 3 / 4]);
x_20 = a_x.idtfs.func('real');
x = DTS.Periodic({-5, 20}, x_20.value);
A_y1 = DTS(w_0 * (0 : 19), x.filter(b1, a1).cut({0, 19}).dtfs).func('abs');
A_y2 = DTS(w_0 * (0 : 19), x.filter(b2, a2).cut({0, 19}).dtfs).func('abs');
A_x = DTS(w_0 * (0 : 19), a_x.value).func('abs');

DTS.Figures("v", ...
    struct("xlabel", "k", "ylabel", "|a[k]|", "xlim", [0, 2 * pi], "ylim", [0, 2.5], "grid", "on"), ...
    { A_x.sInf("|a[k]|", "r"), A_y1.sInf("|a_{y1}[k]|", "b") }, ...
    struct("xlabel", "k", "ylabel", "|a[k]|", "xlim", [0, 2 * pi], "ylim", [0, 2], "grid", "on"), ...
    { A_x.sInf("|a[k]|", "r"), A_y2.sInf("|a_{y2}[k]|", "b") } ...
);
