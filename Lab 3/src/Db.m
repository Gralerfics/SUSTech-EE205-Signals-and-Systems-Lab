clear;

S = 1000;
RC = 1;
x2 = DTS.Identity({0, 20}, S).func('cos').func('sign');
y2 = x2.lsim([1], [RC, 1]);

DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "f(t)", "grid", "on"), ...
    { x2.cut({10, 20}).sInf("x_2(t)", "r", "", "plot"), y2.cut({10, 20}).sInf("y_2(t)", "b", "", "plot") } ...
);
