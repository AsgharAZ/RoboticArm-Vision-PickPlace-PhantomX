function [A] = createA(theta,d,a,alpha)
% The function creates a symbolic transformation matrix based on DH
% parameters passed as arguments to the function. 
%   A = [cos(theta), -sin(theta)cos(alpha), sin(theta)sin(alpha), a cos(theta);
%        sin(theta), cos(theta)cos(alpha), -cos(theta)sin(alpha), a sin(theta);
%        0,          sin(alpha),            cos(alpha),           d;
%        0,          0,                     0,                    1];

theta=sym(theta);
d=sym(d);
a=sym(a);
alpha=sym(alpha);

A = [cos(theta), -sin(theta)*cos(alpha), sin(theta)*sin(alpha), a*cos(theta);
    sin(theta), cos(theta)*cos(alpha), -cos(theta)*sin(alpha), a*sin(theta);
    0, sin(alpha), cos(alpha), d;
    0, 0, 0, 1];
end

