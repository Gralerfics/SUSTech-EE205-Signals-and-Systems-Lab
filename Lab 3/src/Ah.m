clear;

a3 = DTS(circshift(DTS([ones(1, 8), zeros(1, 24)]).dtfs, 15)).shift(15);

v = [0 31];
Arg = {"v"};
for I = 2 : 2 : 16
    Arg = [Arg, {
        struct("xlabel", "t", "ylabel", "x_{3(" + num2str(I) + ")}[n]", "xlim", v, "grid", "on"), ...
        { a3.cut(-I : I).cut(-15 : 16).idtfs.func('real').sInf("x_{3(" + num2str(I) + ")}[n]") }
    }];
end
DTS.Figures(Arg{:});
