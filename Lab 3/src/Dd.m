clear;

S = 1000;
RC = 1;
x2 = DTS.Identity({-5, 20}, S).func('cos').func('sign');
apos_k = DTS(2 * DTS(DTS.Identity({1, 10}) .* pi ./ 2).func('sin') ./ (DTS.Identity({1, 10}) .* pi)).shift(-1).stretch(2).value;
aneg_k = DTS(2 * DTS(DTS.Identity({-10, -1}) .* pi ./ 2).func('sin') ./ (DTS.Identity({-10, -1}) .* pi)).shift(1).stretch(-2).value;
ssum = DTS({0, 0}, 0, S);
ysum = DTS({0, 0}, 0, S);
Idn = DTS.Identity({-5, 20}, S);
for I = 1 : 5
    k = 2 * I - 1;
    s(I) = apos_k(I) * DTS(1j * k * Idn).func('exp') + aneg_k(I) * DTS(-1j * k * Idn).func('exp');
    y(I) = s(I).lsim([1], [RC, 1]);
    ssum = ssum + s(I);
    ysum = ysum + y(I);
end

figure(1);
DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(1).cut({0, 20}).sInf("y_1(t)", "b", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(2).cut({0, 20}).sInf("y_2(t)", "b", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(3).cut({0, 20}).sInf("y_3(t)", "b", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(4).cut({0, 20}).sInf("y_4(t)", "b", "", "plot") }, ...
    struct("xlabel", "t", "ylabel", "y(t)", "grid", "on"), { y(5).cut({0, 20}).sInf("y_5(t)", "b", "", "plot") } ...
);

figure(2);
DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "f(t)", "grid", "on"), ...
    { ssum.lsim([1], [RC, 1]).cut({0, 20}).sInf("Response of s_{sum}(t)", "r", "", "plot"), ysum.cut({0, 20}).sInf("y_{sum}(t)", "b", "--", "plot") } ...
);
