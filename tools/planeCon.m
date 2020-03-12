function [c,ceq]=planeCon(x)
    c=1;
    ceq=norm(x(1:3))-1;
end