function y = diffeqn(a,x,yn1)
    n = length(x);
    for i = 1 : n
        if i == 1
            y(i) = a * yn1 * x(i);
        else
            y(i) = a * y(i - 1) + x(i);
        end
    end
end

% function y = diffeqn(a, x, yn1)
%     y = a * yn1 + x(1);
%     for k = x(2 : end) y = [y, a * y(end) + k];
% end

% function y = diffeqn(a, x, yn1)
%     if length(x) == 1
%         y = a * yn1 + x(end);
%     else
%         y = diffeqn(a, x(1 : end - 1), yn1);
%         y = [ y, a * y(end) + x(end) ];
%     end
% end

% function y = diffeqn(a, x, yn1)
%     l = length(x);
%     y = (l == 1) * a * yn1 + x(l) + (l ~= 1) * diffeqn(a, x(1 : max(end - 1, 1)), yn1);
%     y = [ y, eye(l ~= 1) * a * y(end) + x(l) ];
% end