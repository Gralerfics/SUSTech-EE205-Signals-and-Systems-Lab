classdef DTS
    %{
        [ 一维离散时间信号类 ]
        Latest: 20220312 by Gralerfics
        属性
            domain - 定义域, 行向量
            value - 值, 与 domain 等长行向量
        成员方法
            DTS(domainArg, valueArg) - 构造方法
            filter(xArgs, yArgs) - 单目过滤
            stretch(a) - x[n] --> x[a * n], a 为整且不为 0
            shift(b) - x[n] --> x[n + b], b 为整
            func(s) - 将 value 传入指定函数并将返回值封装为新信号
            cut(s) - 截取信号（截定义域）
            sInf([legend], [color], [style]) - 生成信号绘制信息结构体
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
            Conv(a, b) - 卷积信号 a 与 b
            Filter(B, A, x) - 略
            Stems(Dims, Sigs) - 绘图
                Dims - 结构体, 可含 xlim, ylim, xlabel, ylabel, title, grid 域
                Sigs - Cell 数组, 每个元素为结构体, 必含 signal 域, 可含 legend, style, color 域
            Figures(type, Dims1, Sigs1, ...) - 多子图排列绘图
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
            yValue = obj.value(mod(obj.domain, a) == 0);
            if a < 0
                yDomain = fliplr(yDomain);
                yValue = fliplr(yValue);
            end
            y = DTS(yDomain, yValue);
        end
        function y = shift(obj, b)
            y = DTS((obj.domain(1) - b) : (obj.domain(end) - b), obj.value);
        end
        function y = func(obj, s)
            yDomain = obj.domain;
            yValue = eval(s + "(obj.value);");
            y = DTS(yDomain, yValue);
        end
        function y = cut(obj, s)
            yDomain = s;
            l = max(obj.domain(1) - s(1), 0);
            r = max(s(end) - obj.domain(end), 0);
            yValue = [zeros(1, l) obj.value(ismember(obj.domain, s)) zeros(1, r)];
            y = DTS(yDomain, yValue);
        end
        function rst = sInf(obj, varargin)
            rst.signal = obj;
            if nargin > 1; if varargin{1} ~= ""; rst.legend = varargin{1}; end; end
            if nargin > 2; if varargin{2} ~= ""; rst.color = varargin{2}; end; end
            if nargin > 3; if varargin{3} ~= ""; rst.style = varargin{3}; end; end
            if nargin > 4; if varargin{4} ~= ""; rst.type = varargin{4}; end; end
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
            if class(a) == "double"; a = DTS(b.domain, a * ones(1, length(b.domain))); end
            if class(b) == "double"; b = DTS(a.domain, b * ones(1, length(a.domain))); end
            yDomain = a.domain;
            yValue = a.value .^ b.value;
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
            y = DTS(x.domain, filter(xArgs, yArgs, x.value));
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
                args = {s.domain, s.value};
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
