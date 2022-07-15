classdef DTS
    %{
        [ 一维离散时间信号类 ]
        Latest: 20220316 by Gralerfics
        属性
            domain - 定义域, 行向量
            value - 值, 与 domain 等长行向量
            sample - 采样率, 单位长度内样本数量
            * Warning: 采样率不为 1 时, 构造函数信号注意将自变量换元为原来的 sample 分之一
        成员方法
            DTS(domainArg, valueArg, [sampleArg]) - 构造方法
            filter(xArgs, yArgs) - 单目过滤
            stretch(a) - 将 a * n 代入 n, a 为整且不为 0
            shift(b) - 将 n + b 代入 n, b 为整
            func(s) - 将 value 传入指定函数并将返回值封装为新信号
            cut(s) - 截取信号（截定义域）
            sInf([legend], [color], [style], [type], [sample]) - 生成信号绘制信息结构体
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
            obj.domain = varargin{1};
            if nargin > 1
                if length(varargin{2}) == length(obj.domain)
                    obj.value = varargin{2};
                else
                    error('Wrong interval of value vector!');
                end
            else
                obj.value = zeros(1, length(obj.domain));
            end
            if nargin > 2
                obj.sample = varargin{3};
            else
                obj.sample = 1;
            end
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
            s = s(1) * obj.sample : s(end) * obj.sample;
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
            y = DTS.Conv(a, b);
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
        function z = Conv(x, y)
            if x.sample ~= y.sample; error("Non-identical sampling rates!"); end
            zDomain = (x.domain(1) + y.domain(1)) : (x.domain(end) + y.domain(end));
            zValue = conv(x.value, y.value);
            z = DTS(zDomain, zValue, x.sample);
        end
        function y = Filter(xArgs, yArgs, x)
            y = DTS(x.domain, filter(xArgs, yArgs, x.value), x.sample);
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
