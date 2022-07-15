clear;

S = 1000;
RC = 1;
x2 = DTS.Identity({-5, 20}, S).func('cos').func('sign');
apos_k = DTS(2 * DTS(DTS.Identity({1, 10}) .* pi ./ 2).func('sin') ./ (DTS.Identity({1, 10}) .* pi)).shift(-1).stretch(2).value;
aneg_k = DTS(2 * DTS(DTS.Identity({-10, -1}) .* pi ./ 2).func('sin') ./ (DTS.Identity({-10, -1}) .* pi)).shift(1).stretch(-2).value;
ysum = DTS({0, 0}, 0, S);
Idn = DTS.Identity({-5, 20}, S);
for I = 1 : 5
    k = 2 * I - 1;
    s(I) = apos_k(I) * DTS(1j * k * Idn).func('exp') + aneg_k(I) * DTS(-1j * k * Idn).func('exp');
    y(I) = s(I).lsim([1], [RC, 1]);
    ysum = ysum + y(I);
end

DTS.Figures("v", ...
    struct("xlabel", "t", "ylabel", "f(t)", "grid", "on"), ...
    { x2.lsim([1], [RC, 1]).cut({0, 20}).sInf("Response of s_{sum}(t)", "r", "", "plot"), ysum.cut({0, 20}).sInf("y_{sum}(t)", "b", "--", "plot") } ...
);
