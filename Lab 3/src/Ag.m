clear;

a3 = DTS(circshift(DTS([ones(1, 8), zeros(1, 24)]).dtfs, 15)).shift(15);
x3_all = a3.idtfs;

v = [0 31];
DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "x_{3(all)}[n]", "xlim", v, "grid", "on"), ...
    { x3_all.func('imag').sInf("x_{3(all)}[n]") } ...
);
