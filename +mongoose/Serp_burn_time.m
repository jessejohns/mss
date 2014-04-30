function Serp_burn_time(s_time,t_set,pow,opt)
%% Gen_time
%   This function generates burn time stepping.
%
%  s_time: String for which mode to use:
%          coarse, normal, fine, ultra
%
%  t_set:  vector of time intervals
%
%  pow:    vector of power
%
%  opt:    1 for power being power
%          2 for power being power density

%% Inputs:
% clear; clc; close all
% s_time = 'normal';
% t_set = [500 140 15];
% pow = [400 0 300];

%% Code options
G1 = 20;
a_set = 0.01;

%% Run:

delete burn_steps
diary burn_steps

if strcmp(s_time,'fine')
    m1 = 10;
    m2 = 0.1;
elseif strcmp(s_time,'normal')
    m1 = 5;
    m2 = 0.04;
elseif strcmp(s_time,'coarse')
    m1 = 3;
    m2 = 0.01;
elseif strcmp(s_time,'ultra')
    m1 = 15;
    m2 = 0.15;
end

for i = 1:length(t_set)
    
    if i > 1
        a_set = a_set + t_set(i-1) + 0.01;
    else
        a_set = 0.01;
    end
    
    % Write power:
if opt == 1
    fprintf('\nset power %3.3e \n \n',pow(i))
elseif opt == 2
    fprintf('\nset powdens %3.3e \n \n',pow(i))
else
error('Incorrect power option.')
end
    fprintf('dep daytot \n')
    % Write time steps
    if G1 < t_set(i)
        G1_t = (logspace(0,1,m1)-1)/9*G1+a_set;
        G2_t = (logspace(0,1,ceil(m2*(t_set(i)-G1)))-1)/9*(t_set(i)-G1)+G1+a_set;
        
        fprintf('    %5.2f \n',G1_t)
        fprintf('    %5.2f \n',G2_t(2:end))
    else
        G2_t = (logspace(0,1,m1)-1)/9*t_set(i)+a_set;
        fprintf('    %5.2f \n',G2_t)
    end
end

diary off
