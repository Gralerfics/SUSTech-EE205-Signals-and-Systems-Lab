clear;

S = 1000;
RC = 1;
x2 = DTS.Identity({-5, 20}, S).func('cos').func('sign');
apos_k = DTS(2 * DTS(DTS.Identity({1, 10}) .* pi ./ 2).func('sin') ./ (DTS.Identity({1, 10}) .* pi)).shift(-1).stretch(2).value;
aneg_k = DTS(2 * DTS(DTS.Identity({-10, -1}) .* pi ./ 2).func('sin') ./ (DTS.Identity({-10, -1}) .* pi)).shift(1).stretch(-2).value;
msum = DTS({0, 0}, 0, S);
ysum = DTS({0, 0}, 0, S);
Idn = DTS.Identity({-5, 20}, S);
for I = 1 : 5
    k = 2 * I - 1;
    s(I) = apos_k(I) * DTS(1j * k * Idn).func('exp') + aneg_k(I) * DTS(1j * k * Idn).func('exp');
    m(I) = s(I).lsim([1], [RC, 1]);
    y(I) = apos_k(I) * 1 / (1 + 1j * k) * DTS(1j * k * Idn).func('exp') + aneg_k(I) * 1 / (1 - 1j * k) * DTS(-1j * k * Idn).func('exp');
    ysum = ysum + y(I);
    msum = msum + m(I);
end

figure(1);
DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(1).cut({10, 20}).sInf("y_{1(Analytical)}(t)", "b", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(2).cut({10, 20}).sInf("y_{2(Analytical)}(t)", "b", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(3).cut({10, 20}).sInf("y_{3(Analytical)}(t)", "b", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(4).cut({10, 20}).sInf("y_{4(Analytical)}(t)", "b", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(5).cut({10, 20}).sInf("y_{5(Analytical)}(t)", "b", "", "plot") } ...
);

figure(2);
DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { m(1).cut({10, 20}).sInf("y_{1(Simulation)}(t)", "r", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { m(2).cut({10, 20}).sInf("y_{2(Simulation)}(t)", "r", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { m(3).cut({10, 20}).sInf("y_{3(Simulation)}(t)", "r", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { m(4).cut({10, 20}).sInf("y_{4(Simulation)}(t)", "r", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { m(5).cut({10, 20}).sInf("y_{5(Simulation)}(t)", "r", "", "plot") } ...
);