classdef DTS
    %{
        [ 一维离散时间信号类 ]
        属性
            domain - 定义域, 行向量
            value - 值, 与 domain 等长行向量
        成员方法
            DTS(domainArg, valueArg) - 构造方法
            filter(xArgs, yArgs) - 单目过滤
            stretch(a) - x[n] --> x[a * n], a >= 1 且为整
            shift(b) - x[n] --> x[n + b], b 为整
            func(s) - 将 value 传入指定函数并将返回值封装为新信号
            sInf(legendArg, styleArg) - 生成信号图例样式信息结构体
            以及一系列运算符重载
                plus(+) - 叠加
                minus(-) - 削减
                uminus(-) - 取反
                times(.*) - 按元素乘
                mtimes(*) - 卷积
                rdivide(./) - 右按元素除
                power(.^) - 按元素求幂
                mpower(^) - 连续卷积
        静态方法
            Conv(a, b) - 卷积信号 a 与 b
            Filter(B, A, x) - 略
            Stems(Dims, Sigs) - 绘图
                Dims - 结构体, 可含 xlim, ylim, xlabel, ylabel, title 域
                Sigs - Cell 数组, 每个元素为结构体, 必含 signal 域, 可含 legend, style 域
    %}
    properties
        domain
        value
    end
    methods
        function obj = DTS(domainArg, valueArg)
            obj.domain = domainArg;
            obj.value = valueArg;
        end
        function y = filter(obj, xArgs, yArgs)
            y = DTS.Filter(xArgs, yArgs, obj);
        end
        function y = stretch(obj, a)
            yDomain = obj.domain(mod(obj.domain, a) == 0) ./ a;
            y = DTS(yDomain, obj.value(mod(obj.domain, a) == 0));
        end
        function y = shift(obj, b)
            y = DTS((obj.domain(1) - b) : (obj.domain(end) - b), obj.value);
        end
        function y = func(obj, s)
            yDomain = obj.domain;
            yValue = eval(s + "(obj.value);");
            y = DTS(yDomain, yValue);
        end
        function rst = sInf(obj, legendArg, styleArg)
            rst.signal = obj;
            if legendArg ~= ""
                rst.legend = legendArg;
            end
            if styleArg ~= ""
                rst.style = styleArg;
            end
        end
        function y = plus(a, b)
            if class(a) == "double"; a = DTS(b.domain, a * ones(1, length(b.domain))); end
            if class(b) == "double"; b = DTS(a.domain, b * ones(1, length(a.domain))); end
            yDomain = min(a.domain(1), b.domain(1)) : max(a.domain(end), b.domain(end));
            yValue = zeros(1, length(yDomain));
            y = DTS(yDomain, yValue);
            s = find(y.domain == a.domain(1)); i = s : (s + length(a.value) - 1); y.value(i) = y.value(i) + a.value;
            s = find(y.domain == b.domain(1)); i = s : (s + length(b.value) - 1); y.value(i) = y.value(i) + b.value;
        end
        function y = minus(a, b)
            y = plus(a, uminus(b));
        end
        function y = uminus(a)
            yDomain = a.domain;
            yValue = -a.value;
            y = DTS(yDomain, yValue);
        end
        function y = times(a, b)
            if class(a) == "double"; a = DTS(b.domain, a * ones(1, length(b.domain))); end
            if class(b) == "double"; b = DTS(a.domain, b * ones(1, length(a.domain))); end
            yDomain = min(a.domain(1), b.domain(1)) : max(a.domain(end), b.domain(end));
            yValue = zeros(1, length(yDomain));
            y = DTS(yDomain, yValue);
            s = find(y.domain == a.domain(1)); i = s : (s + length(a.value) - 1); y.value(i) = y.value(i) + a.value;
            s = find(y.domain == b.domain(1)); i = s : (s + length(b.value) - 1); y.value(i) = y.value(i) .* b.value;
        end
        function y = mtimes(a, b)
            y = DTS.Conv(a, b);
        end
        function y = rdivide(a, b)
            if class(a) == "double"; a = DTS(b.domain, a * ones(1, length(b.domain))); end
            if class(b) == "double"; b = DTS(a.domain, b * ones(1, length(a.domain))); end
            yDomain = min(a.domain(1), b.domain(1)) : max(a.domain(end), b.domain(end));
            yValue = zeros(1, length(yDomain));
            y = DTS(yDomain, yValue);
            s = find(y.domain == a.domain(1)); i = s : (s + length(a.value) - 1); y.value(i) = y.value(i) + a.value;
            s = find(y.domain == b.domain(1)); i = s : (s + length(b.value) - 1); y.value(i) = y.value(i) ./ b.value;
        end
        function y = power(a, b)
            yDomain = a.domain;
            yValue = a.value .^ b;
            y = DTS(yDomain, yValue);
        end
        function y = mpower(a, b)
            y = DTS(a.domain, a.value);
            for i = 2 : b
                y = y * a;
            end
        end
    end
    methods(Static)
        function z = Conv(x, y)
            zDomain = (x.domain(1) + y.domain(1)) : (x.domain(end) + y.domain(end));
            zValue = conv(x.value, y.value);
            z = DTS(zDomain, zValue);
        end
        function y = Filter(xArgs, yArgs, x)
            y = DTS(x.domain, filter(xArgs, yArgs, x));
        end
        function Stems(Dims, Sigs)
            hold on, grid on;
            for f = ["xlim", "ylim", "xlabel", "ylabel", "title"]
                if isfield(Dims, f)
                    eval(f + "(Dims." + f + ");");
                end
            end
            handles = [];
            legends = [];
            for i = 1 : length(Sigs)
                sig = Sigs{i};
                style = 'o';
                if isfield(sig, 'style')
                    style = sig.style;
                end
                s = sig.signal;
                h = stem(s.domain, s.value, style);
                if isfield(sig, 'legend')
                    handles = [handles, h];
                    legends = [legends, sig.legend];
                end
            end
            if ~isempty(legends)
                legend(handles, legends');
            end
        end
    end
end
