clear;

S = 1000;
RC = 1;
x = DTS.Identity({0, 20}, S).func('cos');
y = x.lsim([1], [RC, 1]);

DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "f(t)", "grid", "on"), ...
    { x.cut({10, 20}).sInf("x(t)", "r", "", "plot"), y.cut({10, 20}).sInf("y(t)", "b", "", "plot") } ...
);
