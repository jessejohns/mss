% Statisical Testing
%
%  Written by:
%    Jesse Johns
%
%% Description
%
%  This script will analyze an output for statisical checks to verify the
%  quality of a particular run or it will run a case multiple times.
%
%  When running multiple times, the code will find "kcode" and change the
%  parameters to increase the number of histories such that the statistics
%  are below a certain threshold for a desired convergence level.
%
%  Unlike other scripts, this will not automatically find inputs.
%
%  INPUTS:
%
%    dir: Directory of input.
%
%    tar_dir: Working directory for multiple runs.
%
%    fileID: Name of input file.
%
%    opt: 0 - for statiscal checks, 1 - for automaticed runs
%         Default is 0.
%
%    level: 1, 2, 3
%         This indicates, in increaseing number, the fewer number of
%         variables to be checked.  Eg. 1 checks all variable with
%         statistics, 3 checks only major output variables.
%         Default is 1.
%             - See body of the script for which ones these are.
%             - Power distributions are though since the lattic ID is not
%               predictable.
%
%% TODO
%
%  Make a search for the FG_POWDICTR<cell> variables.
%

%% Check for inputs:

if exist('opt','var') == 0
    opt = 0;
end

if exist('level','var') == 0
    level = 1;
end

%% Update log:
%
%  01-25-2013  Jesse Johns
%       Original script creation.
%

%% Variable listing:
%
if level == 1
    %  Highest Level of Variables:
    VAR = {'COL_SLOW','COL_THERM','COL_TOT',...
        'SLOW_TIME','THERM_TIME','SLOW_DIST','THERM_DIST','THERM_FRAC',...
        'ANA_KEFF','IMP_KEFF','COL_KEFF','COL_KEFF','ABS_KEFF','ABS_KINF',...
        'ABS_GC_KEFF','ABS_GC_KINF','IMPL_ALPHA_EIG','FIXED_ALPHA_EIG','GEOM_ALBEDO',...
        'TOT_POWER','TOT_GENRATE','TOT_FISSRATE','TOT_ABSRATE','TOT_LEAKRATE',...
        'TOT_LOSSRATE','TOT_SRCRATE','TOT_FLUX','TOT_RR','TOT_SOLU_ABSRATE',...
        'TOT_POWDENS','BURN_POWER','BURN_GENRATE','BURN_FISSRATE',...
        'BURN_ABSRATE','BURN_FLUX','BURN_POWDENS',...
        'ANA_PROMPT_LIFETIME','IMPL_PROMPT_LIFETIME','ANA_REPROD_TIME',...
        'IMPL_REPROD_TIME','DELAYED_EMTIME','SIX_FF_ETA','SIX_FF_F','SIX_FF_P',...
        'SIX_FF_EPSILON','SIX_FF_LF','SIX_FF_LT','SIX_FF_KINF','SIX_FF_KEFF',...
        'BETA_EFF','BETA_ZERO','DECAY_CONSTANT',...
        'FLUX','LEAK','TOTXS','FISSXS','CAPTXS','ABSXS','RABSXS','ELAXS','INELAXS',...
        'SCATTXS','SCATTPRODXS','N2NXS','REMXS','NUBAR','NSF','RECIPVEL','FISSE',...
        'CHI','CHIP','CHID','GTRANSFP','GTRANSFXS','GPRODP','GPRODXS','DIFFAREA',...
        'DIFFCOEF','TRANSPXS','MUBAR','MAT_BUCKLING','LEAK_DIFFCOEF','SCATT0',...
        'SCATT1','SCATT2','SCATT3','SCATT4','SCATT5','P1_TRANSPXS','P1_DIFFCOEF',...
        'P1_MUBAR','B1_KINF','B1_BUCKLING','B1_FLUX','B1_TOTXS','B1_NSF','B1_FISSXS',...
        'B1_CHI','B1_ABSXS','B1_RABSXS','B1_REMXS','B1_DIFFCOEF','B1_SCATTXS',...
        'B1_SCATTPRODXS','ADFS','ADFC'};
    
elseif level == 2
    
    % Medium level:
    VAR = {'COL_SLOW','COL_THERM','COL_TOT',...
        'SLOW_TIME','THERM_TIME','SLOW_DIST','THERM_DIST','THERM_FRAC',...
        'ANA_KEFF','IMP_KEFF','COL_KEFF','COL_KEFF','ABS_KEFF','ABS_KINF',...
        'ABS_GC_KEFF','ABS_GC_KINF','FIXED_ALPHA_EIG','GEOM_ALBEDO',...
        'TOT_POWER','TOT_GENRATE','TOT_FISSRATE','TOT_ABSRATE','TOT_LEAKRATE',...
        'TOT_LOSSRATE','TOT_FLUX','TOT_RR','TOT_SOLU_ABSRATE',...
        'TOT_POWDENS','BURN_POWER','BURN_GENRATE','BURN_FISSRATE',...
        'BURN_ABSRATE','BURN_FLUX','BURN_POWDENS',...
        'ANA_PROMPT_LIFETIME','IMPL_PROMPT_LIFETIME','ANA_REPROD_TIME',...
        'IMPL_REPROD_TIME','DELAYED_EMTIME','SIX_FF_ETA','SIX_FF_F','SIX_FF_P',...
        'SIX_FF_EPSILON','SIX_FF_LF','SIX_FF_LT','SIX_FF_KINF','SIX_FF_KEFF',...
        'BETA_EFF','BETA_ZERO','DECAY_CONSTANT',...
        'FLUX','LEAK','TOTXS','FISSXS','CAPTXS','ABSXS','RABSXS','ELAXS',...
        'SCATTXS','SCATTPRODXS','REMXS','NUBAR','NSF','RECIPVEL','FISSE',...
        'CHI','CHIP','CHID','GTRANSFP','GTRANSFXS','GPRODP','GPRODXS','DIFFAREA',...
        'DIFFCOEF','TRANSPXS','MUBAR','MAT_BUCKLING','LEAK_DIFFCOEF'};
    
    
elseif level == 3
    
    % Lowest level:
    VAR = {'ANA_KEFF','IMP_KEFF','COL_KEFF','COL_KEFF','ABS_KEFF','ABS_KINF',...
        'ABS_GC_KEFF','ABS_GC_KINF','TOT_POWER','TOT_GENRATE',...
        'TOT_FISSRATE','TOT_ABSRATE','TOT_LEAKRATE',...
        'TOT_LOSSRATE','TOT_FLUX','TOT_RR',...
        'TOT_POWDENS','SIX_FF_ETA','SIX_FF_F','SIX_FF_P',...
        'SIX_FF_EPSILON','SIX_FF_LF','SIX_FF_LT','SIX_FF_KINF','SIX_FF_KEFF',...
        'FLUX','LEAK'};
    
else
    error('Invalid input for "level".')
end

%% Build directory

cd(dir)

if exist('tar_dir','dir') == 0
    mkdir(tar_dir)
end

cd(tar_dir)

%% Main Script

if opt == 0
    
    
    
elseif opt == 1
    
else
    
    error('Unreognized input for "opt".')
    
end