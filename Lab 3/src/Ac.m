clear;

N = 5;
a = DTS([-2 -1 0 1 2], [exp(-1j * pi / 4), 2 * exp(1j * pi / 3), 1, 2 * exp(-1j * pi / 3), exp(1j * pi / 4)]);
x = a.idtfs;

DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "real(x[n])", "grid", "on"), ...
    { x.func('real').sInf("x[n]", "r") }, ...
    struct("xlabel", "t", "ylabel", "imag(x[n])", "grid", "on"), ...
    { x.func('imag').sInf("x[n]_{imag}", "b") } ...
);
