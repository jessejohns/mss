function Serp_ke1(x,y)
%
%  This function finds the time where the eigenvalue equals unity.
%
%
%  Inputs:
%    x - BURN_DAYS
%    y - ABS_KEFF
%
X = linspace(x(1),x(end),600);
Y = interp1(x,y,X,'linear');

