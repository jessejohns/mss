% function PWR_gen(cy_len,cpf,pow,type,run,op)
%
% This function generates a PWR assembly Serpent model and burnup script,
% and can run the script.  Additionally, the script will pull major data
% from the results and print them in a text file.
%
% Written by: Jesse Johns
%             Texas A&M University
%
% -----------------------------------------------------------------------
%                         INPUTS
%------------------------------------------------------------------------
% cy_len
%
%   This defines the cycle length for an entire cycle, including the decay
%   steps. This can be defined as an array to declare multiple cycles. The
%   definition is in months, where 1 month is 30.4375 days.
%
% cpf
%
%   This defines the capacity factor to be used.  If cy_len is 365 days,
%   then the capacity factor will define the burnup length as 365*cpf and
%   the decay step as 365*(1-cpf). If cy_len is an array, then cpf must be
%   the same length.
%
% pow
%
%   This defines the linear power of a single assembly in W/cm.
%
% type
%
%   This defines which type of lattice to use:
%    1 - Infinite assembly without burnables
%    2 - Infinite assembly with burnables
%    3 - 3x3 infinite assembly with varied surrounding assemblies (see op)
%        and surrounding assemblies are not burned.
%    4 - 3x3 infinite assembly with varied surrounding assemblies (see op)
%        and all assemblies are burned.
%
%   In the 3x3 geometries, only the isotopics of the center assembly are
%   investigated.  Whether the outter assemblies are to be burned will be
%   decided.
%
%   If a critical search with boron dilution is to be included, make the
%   type into an array where the second entry is > 1.
%
% run
%
%   This defines whether this script runs or just generates the input
%   decks.
%     1 - run
%     2 - run and record data
%     omit - generate inputs deck
%
% op
%
%   This contains a matrix for options.
%   3 x 3 definition, if not supplied uses default values.
%     op = [9,2]
%        where [9,1] defines if including burnables
%                       1 = no, 2 = yes
%              [9,2] defines enrichment in percent
%
% -----------------------------------------------------------------------
% MPI
b_mpi = 3;
c_mpi = 5;
%% Example inputs:
cy_len = 12;
cpf = .9;
pow = 360;
type = 1;
run = 1;
op = [1 1 1 1 2 1 1 1 1; 4.5 4.5 4.5 4.5 4.5 4.5 4.5 4.5 4.5];

% Current directory:
cur_dir = pwd;

%% Make directory with user name and date:
[status,user_result] = dos('whoami');

user_name = regexp(user_result,'\','split');

work_dir = ['PWR_bu_' datestr(today) '_' user_name{2}];

mk_string = ['mkdir' ' ' work_dir];
eval(mk_string)

cd_string = ['cd' ' ' work_dir];
eval(cd_string)

%% Build burnup history

delete burn_steps
diary burn_steps

f_set = logspace(0,3,20)/1000;
d_set = logspace(0,2,10)/100;
conv = 30.4375;

fprintf('set power %5.3f\n',pow)
fprintf('dep daystep\n')
for i = 1:length(f_set)
    fprintf('  %5.2f\n',f_set(i)*cy_len*cpf*conv)
end
fprintf('\n')
fprintf('set power 0\n')
fprintf('dep daystep\n')
for i = 1:length(d_set)
    fprintf('  %5.2f\n',d_set(i)*cy_len*(1-cpf)*conv)
end

diary off

%% Build inventory list

delete burn_inven
diary burn_inven

fprintf('set inventory\n')
fprintf('             \n')
fprintf(' 922340      \n')
fprintf(' 922350      \n')
fprintf(' 922360      \n')
fprintf(' 922370      \n')
fprintf(' 922380      \n')
fprintf(' 922390      \n')
fprintf(' 932360      \n')
fprintf(' 932370      \n')
fprintf(' 932380      \n')
fprintf(' 932390      \n')
fprintf(' 942360      \n')
fprintf(' 942380      \n')
fprintf(' 942390      \n')
fprintf(' 942400      \n')
fprintf(' 942410      \n')
fprintf(' 942420      \n')
fprintf(' 942430      \n')
fprintf(' 952410      \n')
fprintf(' 952420      \n')
fprintf(' 952430      \n')
fprintf(' 952440      \n')
fprintf(' 952421      \n')
fprintf(' 962420      \n')
fprintf(' 962430      \n')
fprintf(' 962440      \n')
fprintf(' 962450      \n')
fprintf(' 962460      \n')
fprintf(' 962470      \n')
fprintf(' 962480      \n')
fprintf(' 962490      \n')
fprintf(' 972490      \n')
fprintf(' 972500      \n')
fprintf(' 982490      \n')
fprintf(' 982500      \n')
fprintf(' 982510      \n')
fprintf(' 982520      \n')
fprintf(' 360830      \n')
fprintf(' 451030      \n')
fprintf(' 451050      \n')
fprintf(' 471090      \n')
fprintf(' 531350      \n')
fprintf(' 541310      \n')
fprintf(' 541350      \n')
fprintf(' 551330      \n')
fprintf(' 551340      \n')
fprintf(' 551350      \n')
fprintf(' 551370      \n')
fprintf(' 561400      \n')
fprintf(' 571400      \n')
fprintf(' 601430      \n')
fprintf(' 601450      \n')
fprintf(' 611470      \n')
fprintf(' 611480      \n')
fprintf(' 611490      \n')
fprintf(' 611481      \n')
fprintf(' 621470      \n')
fprintf(' 621490      \n')
fprintf(' 621500      \n')
fprintf(' 621510      \n')
fprintf(' 621520      \n')
fprintf(' 631530      \n')
fprintf(' 631540      \n')
fprintf(' 631550      \n')
fprintf(' 631560      \n')
fprintf(' 641520      \n')
fprintf(' 641540      \n')
fprintf(' 641550      \n')
fprintf(' 641560      \n')
fprintf(' 641570      \n')
fprintf(' 641600      \n')

diary off

%% Build Serpent deck

delete Reactor_model
diary Reactor_model

%% Geometry

if type == 1 || type == 2
    fprintf('set title "PWR Burnup"                            \n')
    fprintf('                                                  \n')
    fprintf('%% --- Fuel pins:                                  \n')
    fprintf('                                                  \n')
    fprintf('pin 10                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 11                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 12                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 13                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 14                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 15                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 16                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 17                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 18                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 19                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 20                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 21                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 22                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 23                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 24                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 25                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 26                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 27                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 28                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 29                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 30                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 31                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 32                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 33                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 34                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 35                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 36                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 37                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 38                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 39                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 40                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 41                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 42                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 43                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 44                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('pin 45                                            \n')
    fprintf('UO2     0.4025                                    \n')
    fprintf('clad    0.4750                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    
    if type == 1
        fprintf('pin 50                                            \n')
        fprintf('UO2     0.4025                                    \n')
        fprintf('clad    0.4750                                    \n')
        fprintf('water                                             \n')
        fprintf('                                                  \n')
        fprintf('pin 51                                            \n')
        fprintf('UO2     0.4025                                    \n')
        fprintf('clad    0.4750                                    \n')
        fprintf('water                                             \n')
        fprintf('                                                  \n')
        fprintf('pin 52                                            \n')
        fprintf('UO2     0.4025                                    \n')
        fprintf('clad    0.4750                                    \n')
        fprintf('water                                             \n')
        
    elseif type == 2
        fprintf('pin 50                                            \n')
        fprintf('UO2Gd     0.4025                                  \n')
        fprintf('clad    0.4750                                    \n')
        fprintf('water                                             \n')
        fprintf('                                                  \n')
        fprintf('pin 51                                            \n')
        fprintf('UO2Gd     0.4025                                  \n')
        fprintf('clad    0.4750                                    \n')
        fprintf('water                                             \n')
        fprintf('                                                  \n')
        fprintf('pin 52                                            \n')
        fprintf('UO2Gd     0.4025                                  \n')
        fprintf('clad    0.4750                                    \n')
        fprintf('water                                             \n')
    end
    
    fprintf('                                                  \n')
    fprintf('%% --- Guide tube:                                 \n')
    fprintf('                                                  \n')
    fprintf('pin 90                                            \n')
    fprintf('water   0.5730                                    \n')
    fprintf('tube    0.6130                                    \n')
    fprintf('water                                             \n')
    fprintf('                                                  \n')
    fprintf('%% --- Pin lattice:                                \n')
    fprintf('                                                  \n')
    fprintf('lat 110  1  0.0 0.0 17 17  1.265                  \n')
    fprintf('                                                  \n')
    fprintf('45 44 43 42 41 40 39 38 37 38 39 40 41 42 43 44 45\n')
    fprintf('44 36 35 34 33 32 31 30 29 30 31 32 33 34 35 36 44\n')
    fprintf('43 35 28 27 52 90 26 25 90 25 26 90 52 27 28 35 43\n')
    fprintf('42 34 27 90 24 23 22 21 51 21 22 23 24 90 27 34 42\n')
    fprintf('41 33 52 24 20 19 18 17 16 17 18 19 20 24 52 33 41\n')
    fprintf('40 32 90 23 19 90 15 14 90 14 15 90 19 23 90 32 40\n')
    fprintf('39 31 26 22 18 15 50 13 12 13 50 15 18 22 26 31 39\n')
    fprintf('38 30 25 21 17 14 13 11 10 11 13 14 17 21 25 30 38\n')
    fprintf('37 29 90 51 16 90 12 10 90 10 12 90 16 51 90 29 37\n')
    fprintf('38 30 25 21 17 14 13 11 10 11 13 14 17 21 25 30 38\n')
    fprintf('39 31 26 22 18 15 50 13 12 13 50 15 18 22 26 31 39\n')
    fprintf('40 32 90 23 19 90 15 14 90 14 15 90 19 23 90 32 40\n')
    fprintf('41 33 52 24 20 19 18 17 16 17 18 19 20 24 52 33 41\n')
    fprintf('42 34 27 90 24 23 22 21 51 21 22 23 24 90 27 34 42\n')
    fprintf('43 35 28 27 52 90 26 25 90 25 26 90 52 27 28 35 43\n')
    fprintf('44 36 35 34 33 32 31 30 29 30 31 32 33 34 35 36 44\n')
    fprintf('45 44 43 42 41 40 39 38 37 38 39 40 41 42 43 44 45\n')
    fprintf('                                                  \n')
    fprintf('%% --- assembly data:                              \n')
    fprintf('                                                  \n')
    fprintf('surf  1000  sqc  0.0 0.0 10.752                   \n')
    fprintf('surf  1001  sqc  0.0 0.0 10.806                   \n')
    fprintf('                                                  \n')
    fprintf('cell 110  0  fill 110   -1000                     \n')
    fprintf('cell 111  0  water       1000 -1001               \n')
    fprintf('cell 112  0  outside     1001                     \n')
    
elseif type == 3
    
end

fprintf('include "materials"\n')
fprintf('include "options"\n')

if length(type) > 1
    fprintf('include "boron_add"\n')
end

diary off

%% Materials

delete materials
diary materials

if type == 1 || type == 2
    fprintf('mat UO2    6.7402E-02  burn 5         \n')
    fprintf('92234.09c  9.1361E-06                 \n')
    fprintf('92235.09c  9.3472E-04                 \n')
    fprintf('92238.09c  2.1523E-02                 \n')
    fprintf(' 8016.09c  4.4935E-02                 \n')
    fprintf('                                      \n')
    fprintf('mat clad   3.8510E-02                 \n')
    fprintf('26000.06c  1.3225E-04                 \n')
    fprintf('24000.06c  6.7643E-05                 \n')
    fprintf('40000.06c  3.8310E-02                 \n')
    fprintf('                                      \n')
    fprintf('mat tube   4.3206E-02                 \n')
    fprintf('26000.06c  1.4838E-04                 \n')
    fprintf('24000.06c  7.5891E-05                 \n')
    fprintf('40000.06c  4.2982E-02                 \n')
    fprintf('                                      \n')
    fprintf('therm lwtr lwj3.11t                   \n')
    
    if type == 2
        fprintf(' \n')
        fprintf('mat UO2Gd  6.8366E-02  burn 10 \n')
        fprintf('92234.09c  4.2940E-06 \n')
        fprintf('92235.09c  5.6226E-04 \n')
        fprintf('92238.09c  2.0549E-02 \n')
        fprintf('64154.09c  4.6173E-05 \n')
        fprintf('64155.09c  2.9711E-04 \n')
        fprintf('64156.09c  4.1355E-04 \n')
        fprintf('64157.09c  3.1518E-04 \n')
        fprintf('64158.09c  4.9786E-04 \n')
        fprintf('64160.09c  4.3764E-04 \n')
        fprintf(' 8016.09c  4.5243E-02 \n')
    end  
end

if length(type) == 1
    fprintf(' \n')
    fprintf('mat water  7.2216E-02  moder lwtr 1001\n')
    fprintf(' 1001.06c  2                 \n')
    fprintf(' 8016.06c  1                 \n')
end

diary off

%% Critical search

% Do a critical search on boron, which needs be be done between burnup
% steps.  Consult manual on this... it has an option.
%   Critical Search parameters:
dT = 1;
b_ppm(1) = 500;
i = 0;
damp = .75;
keff = 1.0;

diary boron_add

while dT > 0.001
    i = i + 1;
    
    Na = 0.60221367;
    M_b10 = 10.01293703;
    M_b11 = 11.00930547;
    M_h = 1.007825032;
    M_h2o = 18.01505006;
    
    rho_w = 0.71;
    
    eb10 = 0.199;
    
    n_h2o = rho_w*Na/M_h2o;
    n_h3bo3 = n_h2o*b_ppm(i)/1e6;
    
    if length(type) > 1
        fprintf('  \n')
        fprintf('mat water  7.2216E-02  moder lwtr 1001\n')
        fprintf(' 1001.06c  %5.4f                 \n',2*n2ho+3*n_h3bo3)
        fprintf(' 8016.06c  %5.4f                 \n',n2ho+3*n_h3bo3)
        fprintf(' 5010.06c  %5.4f                 \n',n_h3bo3*eb10)
        fprintf(' 5011.06c  %5.4f                 \n',n_h3bo3*(1-eb10))
    else 
        dT = 0.0;
    end
diary off

%% Run

delete options
diary options

fprintf('%% ---------- Options files ------------ \n')
fprintf(' \n')
fprintf('set ures 1 92235.09c 92238.09c 94239.09c 8016.09c 40000.06c  \n')
fprintf(' \n')
fprintf('include "datafile"\n')

% For the criticality run:
if length(type)>1 && dT > 0.001
    fprintf('set pop 80000 100 10 \n')
    diary off
    
    % Run serpent
    tic
    h_string = ['!sss -mpi ' c_mpi 'Reactor_model'];
    eval(h_string)
    run_time = toc;
    
    Reactor_model_res
    
    k(i) = ABS_KEFF(1);
    k_er(i) = ABS_KEFF(2);
    
    diary results
    fprintf('\n --------- Critiality Search \n') 
    fprintf('    The effective eigen value is: %5.3f +/- %5.3f \n',k,k_er)
    fpritnf('    The boron concentration is: %5.3f ppm \n',b_ppm)
    fprintf('    The runtime was: %5.3f s \n',run_time)
    diary off
    
    if i > 1;
        b_ppm(i+1) = b_ppm(i) + (keff-k(i))*(b_ppm(i)-b_ppm(i-1))/...
            (k(i)-k(i-1))*damp;
    elseif i == 1
        if k < 1
            b_ppm(2) = 450;
        else
            b_ppm(2) = 550;
        end
    end
    
    dT(i) = abs(keff - k(i));
    
    if i > 1;
        rat(i) = dT(i)/(k(i)-k(i-1));
    end
    
% For burnup
else
    fprintf('\n%% --------- Burnup --------\n')
    fprintf('include "burn_steps"\n')
    fprintf('include "burn_inventory"\n')
    fprintf('\n')
    fprintf('set bumode 1\n')
    fprintf('set pcc 1\n')
    fprintf('set xscalc 2\n')
    fprintf('set printm 1\n')
    fprintf(' \n')
    fprintf('set pop 20000 100 10 \n')
end

diary off

end

Reactor_model_res

cd(cur_dir)

%% Verify burnup limits

%% Print data
