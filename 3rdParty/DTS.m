classdef DTS
    %{
        [ 一维离散时间信号类 ]
        Latest: 20220407 by Gralerfics
        属性
            domain - 定义域, 行向量
            value - 值, 与 domain 等长行向量
            sample - 采样率, 单位长度内样本数量
                * Warning: 采样率不为 1 时, 构造函数信号注意将自变量换元为原来的 1 / sample;
        成员方法
            DTS(domainArg, valueArg, [sampleArg]) - 构造方法
                * 仅一个参数（valueArg）时默认 domainArg 为 0 : length(valueArg) - 1; 若该参数为 DTS 类型则表复制功能.
                * 若直接给出 domainArg 向量, 单位时间长度为 1 / sample, 即两向量长度要相同.
                * 若采用 {l, r} 作为 domainArg, 则单位时间长度为 1, 自动生成采样总数长度的向量.
                  而 length(valueArg) 需为 (r - l) * sampleArg + 1.
                * 若 valueArg 长度不合要求, 但为一个标量, 则用该量填充到合法长度.
            filter(xArgs, yArgs) - 单目 Filter
            lsim(xArgs, yArgs) - 单目 Lsim
            dtfs() - 单目 Dtfs
            idtfs() - 单目 IDtfs
            fft() - 单目 FFT
            ifft() - 单目 IFFT
            stretch(a) - 将 a * n 代入 n, a 为整且不为 0
            shift(b) - 将 n + b 代入 n, b 为整
                * 以上两个操作的单位时间长度为 1.
                * 例如: x[n] --shift(2)-> x[n + 2] --stretch(2)-> x[2n + 2].
            func(s) - 将 value 传入指定函数并将返回值封装为新信号
                * 形如 func(x[n]). 若要 func(n) 请借助 Identity 生成 x[n] = n.
            cut(s) - 截取信号（截定义域）
                * 单位时间长度为 1.
            toPeriod(x) - 单目 Toperiod
            sInf([legend], [color], [style], [type]) - 生成信号绘制信息结构体
            以及一系列算符重载
                plus(+) - 叠加
                minus(-) - 削减
                uminus(-) - 取反
                times(.*) - 按元素乘
                mtimes(*) - 卷积
                rdivide(./) - 右按元素除
                power(.^) - 按元素求幂
                mpower(^) - 连续卷积
        静态方法
            Step(domainArg, [sample]) - 单位阶跃函数
            Impulse(domainArg, [sample]) - 单位脉冲函数
            Identity(domainArg, [sample]) - 单位函数, y = x
            Periodic(domainArg, valueArg) - 生成离散周期函数
            Toperiod(x) - 将传入的信号视为一个周期, 将其归一化至 [0, N - 1]
            Conv(a, b) - 卷积信号 a 与 b
            Pconv(a, b) - 周期卷积 a 与 b, 返回结果的 [0, N - 1] 周期
            Pconvfft(a, b) - FFT 加速的周期卷积
            Filter(B, A, x) - 差分方程系统响应（B, A 升序; 即 y[n - 0] 优先）
            Lsim(B, A, x) - 微分方程系统响应（B, A 降序; 即 y(k)(n) 优先）
            GetE(N) - 计算 E 矩阵
            Dtfs(x) - Discrete Fourier Series, 传入一个周期长度信号, 返回信号, 会按定义域调节
            Idtfs(x) - Synthesis, 传入 N 长度信号, 返回向量, 会按定义域调节
            Fft(x) - fft(x), Fast Fourier Transform, 传入一个周期的信号, 从 0 开始
            Ifft(a) - ifft(a), 返回一个周期的信号, 从 0 开始
            Freqz(xArgs, yArgs, S) - 差分方程系统频率响应
            Stems(Dims, Sigs) - 绘图
                Dims - 结构体, 可含 xlim, ylim, xlabel, ylabel, title, grid 域
                Sigs - Cell 数组, 每个元素为结构体, 必含 signal 域, 可含 legend, style, color 域
            Figures(type, Dims1, Sigs1, ...) - 多子图排列绘图
    %}
    properties
        domain
        value
        sample
    end
    methods (Access = private)
        function [ra, rb] = checkTwo(a, b)
            ra = a;
            rb = b;
            if class(ra) == "double"; ra = DTS(rb.domain, ra * ones(1, length(rb.domain)), rb.sample); end
            if class(rb) == "double"; rb = DTS(ra.domain, rb * ones(1, length(ra.domain)), ra.sample); end
            if ra.sample ~= rb.sample; error("Non-identical sampling rates!"); end
        end
        function y = mergeTwo(a, b)
            yDomain = min(a.domain(1), b.domain(1)) : max(a.domain(end), b.domain(end));
            yValue = zeros(1, length(yDomain));
            y = DTS(yDomain, yValue, a.sample);
        end
    end
    methods
        function obj = DTS(varargin)
            if nargin == 1
                if class(varargin{1}) == "DTS"
                    obj = varargin{1};
                else
                    obj = DTS(0 : length(varargin{1}) - 1, varargin{1});
                end
            else
                if nargin > 2
                    obj.sample = varargin{3};
                else
                    obj.sample = 1;
                end
                if class(varargin{1}) == "cell"
                    obj.domain = varargin{1}{1} * obj.sample : varargin{1}{2} * obj.sample;
                else
                    obj.domain = varargin{1};
                end
                if nargin > 1
                    if length(varargin{2}) == length(obj.domain)
                        obj.value = varargin{2};
                    elseif length(varargin{2}) == 1
                        obj.value = varargin{2}(1) .* ones(1, length(obj.domain));
                    else
                        error('Wrong interval of value vector!');
                    end
                else
                    obj.value = zeros(1, length(obj.domain));
                end
            end
        end
        function y = filter(obj, xArgs, yArgs)
            y = DTS.Filter(xArgs, yArgs, obj);
        end
        function y = lsim(obj, xArgs, yArgs)
            y = DTS.Lsim(xArgs, yArgs, obj);
        end
        function a = dtfs(obj)
            a = DTS.Dtfs(obj);
        end
        function x = idtfs(obj)
            x = DTS.Idtfs(obj);
        end
        function a = fft(obj)
            a = DTS.Fft(obj);
        end
        function x = ifft(obj)
            x = DTS.Ifft(obj);
        end
        function y = stretch(obj, a)
            yDomain = obj.domain(mod(obj.domain, a) == 0) ./ a;
            yValue = obj.value(mod(obj.domain, a) == 0);
            if a < 0
                yDomain = fliplr(yDomain);
                yValue = fliplr(yValue);
            end
            y = DTS(yDomain, yValue, obj.sample);
        end
        function y = shift(obj, b)
            y = DTS((obj.domain(1) - b * obj.sample) : (obj.domain(end) - b * obj.sample), obj.value, obj.sample);
        end
        function y = func(obj, s)
            yDomain = obj.domain;
            yValue = eval(s + "(obj.value);");
            y = DTS(yDomain, yValue, obj.sample);
        end
        function y = cut(obj, s)
            if class(s) == "cell"
                s = s{1} * obj.sample : s{2} * obj.sample;
            else
                s = s(1) * obj.sample : s(end) * obj.sample;
            end
            yDomain = s;
            l = max(obj.domain(1) - s(1), 0);
            r = max(s(end) - obj.domain(end), 0);
            yValue = [zeros(1, l) obj.value(ismember(obj.domain, s)) zeros(1, r)];
            y = DTS(yDomain, yValue, obj.sample);
        end
        function rst = sInf(obj, varargin)
            rst.signal = obj;
            if nargin > 1; if varargin{1} ~= ""; rst.legend = varargin{1}; end; end
            if nargin > 2; if varargin{2} ~= ""; rst.color = varargin{2}; end; end
            if nargin > 3; if varargin{3} ~= ""; rst.style = varargin{3}; end; end
            if nargin > 4; if varargin{4} ~= ""; rst.type = varargin{4}; end; end
        end
        function y = toPeriod(obj)
            y = DTS.Toperiod(obj);
        end
        function y = plus(a, b)
            [a, b] = checkTwo(a, b);
            y = mergeTwo(a, b);
            s = find(y.domain == a.domain(1)); i = s : (s + length(a.value) - 1); y.value(i) = y.value(i) + a.value;
            s = find(y.domain == b.domain(1)); i = s : (s + length(b.value) - 1); y.value(i) = y.value(i) + b.value;
        end
        function y = minus(a, b)
            y = plus(a, uminus(b));
        end
        function y = uminus(a)
            yDomain = a.domain;
            yValue = -a.value;
            y = DTS(yDomain, yValue, a.sample);
        end
        function y = times(a, b)
            [a, b] = checkTwo(a, b);
            y = mergeTwo(a, b);
            s = find(y.domain == a.domain(1)); i = s : (s + length(a.value) - 1); y.value(i) = y.value(i) + a.value;
            s = find(y.domain == b.domain(1)); i = s : (s + length(b.value) - 1); y.value(i) = y.value(i) .* b.value;
        end
        function y = mtimes(a, b)
            if class(a) == "double" || class(b) == "double"
                y = a .* b;
            else
                y = DTS.Conv(a, b);
            end
        end
        function y = rdivide(a, b)
            [a, b] = checkTwo(a, b);
            y = mergeTwo(a, b);
            s = find(y.domain == a.domain(1)); i = s : (s + length(a.value) - 1); y.value(i) = y.value(i) + a.value;
            s = find(y.domain == b.domain(1)); i = s : (s + length(b.value) - 1); y.value(i) = y.value(i) ./ b.value;
        end
        function y = power(a, b)
            [a, b] = checkTwo(a, b);
            y = mergeTwo(a, b);
            s = find(y.domain == a.domain(1)); i = s : (s + length(a.value) - 1); y.value(i) = y.value(i) + a.value;
            s = find(y.domain == b.domain(1)); i = s : (s + length(b.value) - 1); y.value(i) = y.value(i) .^ b.value;
        end
        function y = mpower(a, b)
            y = DTS(a.domain, a.value, a.sample);
            for i = 2 : b
                y = y * a;
            end
        end
    end
    methods (Static)
        function u = Step(varargin)
            s = 1;
            if nargin > 1; s = varargin{2}; end
            u = DTS(varargin{1}, 0, s);
            u.value = u.domain >= 0;
        end
        function d = Impulse(varargin)
            s = 1;
            if nargin > 1; s = varargin{2}; end
            d = DTS(varargin{1}, 0, s);
            d.value(d.domain == 0) = s;
        end
        function y = Identity(varargin)
            s = 1;
            if nargin > 1; s = varargin{2}; end
            y = DTS(varargin{1}, 0, s);
            y.value = y.domain ./ s;
        end
        function y = Periodic(domainArg, valueArg)
            y = DTS(domainArg, valueArg(mod(domainArg{1} : domainArg{2}, length(valueArg)) + 1));
        end
        function y = Toperiod(x)
            y = DTS(circshift(x.value, x.domain(1)));
        end
        function z = Conv(x, y)
            if x.sample ~= y.sample; error("Non-identical sampling rates!"); end
            zDomain = (x.domain(1) + y.domain(1)) : (x.domain(end) + y.domain(end));
            zValue = conv(x.value, y.value) ./ x.sample;
            z = DTS(zDomain, zValue, x.sample);
        end
        function z = Pconv(x, y)
            if length(x.domain) ~= length(y.domain); error("Period should be equivalent!"); end
            N = length(x.domain);
            z = DTS.Toperiod(x) * (DTS.Toperiod(y) + DTS.Toperiod(y).shift(N));
            z = z.cut(0 : N - 1);
        end
        function z = Pconvfft(x, y)
            if length(x.domain) ~= length(y.domain); error("Period should be equivalent!"); end
            N = length(x.domain);
            az = DTS.Toperiod(x).fft .* DTS.Toperiod(y).fft ./ N;
            z = DTS(az).ifft * N;
        end
        function y = Filter(xArgs, yArgs, x)
            y = DTS(x.domain, filter(xArgs, yArgs, x.value), x.sample);
        end
        function y = Lsim(xArgs, yArgs, x)
            y = DTS(x.domain, lsim(xArgs, yArgs, x.value, x.domain / x.sample)', x.sample);
        end
        function E = GetE(N)
            E = exp(2 * pi * 1j / N) .^ reshape(fix((0 : N * N - 1) / N) .* mod((0 : N * N - 1), N), N, N);
        end
        function a = Dtfs(x)
            if x.sample ~= 1; error('This can be applied to DT Signals (sample = 1)!'); end
            N = length(x.domain);
            E = DTS.GetE(N);
            a = transpose(E' * transpose(circshift(x.value, x.domain(1))) / N);
        end
        function x = Idtfs(a)
            N = length(a.domain);
            A = transpose(a.value) * ones(1, N);
            NK = (a.domain' * ones(1, N)) .* (ones(1, N)' * (0 : N - 1));
            x = DTS({0, N - 1}, sum(A .* exp(1j .* NK .* (2 * pi / N))));
        end
        function a = Fft(x)
            a = fft(x.value);
        end
        function x = Ifft(a)
            x = DTS(ifft(a.value));
        end
        function [h, w] = Freqz(xArgs, yArgs, S)
            [h, w] = freqz(xArgs, yArgs, S, "whole");
        end
        function Stems(Dims, Sigs)
            hold on;
            for f = ["xlim", "ylim", "xlabel", "ylabel", "title", "grid"]
                if isfield(Dims, f)
                    eval(f + "(Dims." + f + ");");
                end
            end
            handles = [];
            legends = [];
            for i = 1 : length(Sigs)
                sig = Sigs{i};
                s = sig.signal;
                args = {s.domain ./ s.sample, s.value};
                if isfield(sig, 'style')
                    args = [args, {sig.style}];
                end
                if isfield(sig, 'color')
                    args = [args, 'color', {sig.color}];
                end
                args = [args, {'lineWidth', 1}];
                h = nan;
                if isfield(sig, 'type')
                    switch sig.type
                        case "plot"
                            h = plot(args{:});
                        otherwise
                            h = stem(args{:});
                    end
                else
                    h = stem(args{:});
                end
                if isfield(sig, 'legend')
                    handles = [handles, h];
                    legends = [legends, sig.legend];
                end
            end
            if ~isempty(legends)
                legend(handles, legends');
            end
        end
        function Figures(varargin)
            n = (nargin - 1) / 2;
            switch varargin{1}
                case "v"
                    p = 100 * n + 10;
                case "h"
                    p = 100 + n * 10;
            end
            for i = 1 : n
                subplot(p + i);
                DTS.Stems(varargin{i * 2}, varargin{i * 2 + 1});
            end
        end
    end
end
