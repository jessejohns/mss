% function Serp_stat_test(prefix,man,type,error_tol)
%
%  This function runs through all parameters in a Serpent 1 or 2
%  result file and prints a files with statistical test results
%  for any parameter that is statisically different. The parameter
%  of comparison is the first directory (or last in man = 3).
%
%  All versions should be compatable.  This script will skip variables
%  that are not present and print them, just to verify they weren't typos.
%  Some variable might be missing with latest versions of Serpent.  Those
%  that are currently used:
%
%    Serpent 1.1.17
%    Serpent 2.1.4
%
%  If anything is missing (some code options outputs are not included),
%  please contact me:
%
%   Jesse Johns
%   Texas A&M University
%   jesse.m.johns@gmail.com
%
%% Testing inputs:
clear; clc; close all

prefix = 'VVER';
man = 2;
error_tol = .05;
inc_er = 0;

data_dir = 'Results';

%%  Documentation:
%
%  prefix
%
%  fileID: This is the name of the input file used.
%             - note, this script requires that the input file
%               for each run be the same.
%
%  Man option:
%    1, The prefix values are directly inputted:
%       prefix = {'Folder_1' 'Folder_2'}
%
%    2, The prefix is a directory to search through.
%
%    3, Same as option 2, but reverses the order of search.
%
%% TODO
%  Plotter for data
%  Detector searches
%
%  How to improve:
%   Add a data directory and more file information.
%      - Date
%   Make a seperate column for the compared sets.
%   Plot the data and their errors, then the error in the data.

%% Delete diaries:
top_dir = pwd;

% Build data directory:
if exist(data_dir,'dir')
    ...
else
    mkdir(data_dir)
end

cd(data_dir)
data_dir = pwd;    % Redefine with absolute directory.
cd(top_dir)

if man ~=1
    cd(prefix)
end

% File names
mis_fil = [prefix '_missing_variable'];
err_fil = [prefix '_error.csv'];

cd(data_dir)

del_string = ['delete ' mis_fil ' ' err_fil];

eval(del_string);
cd(top_dir)

%%  Build folder list:
if man == 2;
    fold = build_dir(prefix);
    
elseif man == 3;
    fold = build_dir(prefix,1);
    
elseif man == 1;
    fold = {prefix};
    fold = fold{1};
else
    error('"Man" input required and missing.')
end

%% List:
%
%  This likely needs to be reviewed to ensure that nothing of importance is
%  missing.

VAR = {'TOT_CPU_TIME','RUNNING_TIME','INIT_TIME','TRANSPORT_CYCLE_TIME',...
    'BURNUP_CYCLE_TIME','PROCESS_TIME','FISSION_FRACTION','CAPTURE_FRACTION',...
    'ELASTIC_FRACTION','INELASTIC_FRACTION','COL_SLOW','COL_THERM','COL_TOT',...
    'SLOW_TIME','THERM_TIME','SLOW_DIST','THERM_DIST','THERM_FRAC','TOT_ACTIVITY',...
    'TOT_DECAY_HEAT','TOT_SF_RATE','ACTINIDE_ACTIVITY','ACTINIDE_DECAY_HEAT',...
    'FISSION_PRODUCT_ACTIVITY','FISSION_PRODUCT_DECAY_HEAT','ENTROPY_TOT',...
    'ANA_KEFF','IMP_KEFF','COL_KEFF','COL_KEFF','ABS_KEFF','ABS_KINF',...
    'ABS_GC_KEFF','ABS_GC_KINF','IMPL_ALPHA_EIG','FIXED_ALPHA_EIG','GEOM_ALBEDO',...
    'TOT_POWER','TOT_GENRATE','TOT_FISSRATE','TOT_ABSRATE','TOT_LEAKRATE',...
    'TOT_LOSSRATE','TOT_SRCRATE','TOT_FLUX','TOT_RR','TOT_SOLU_ABSRATE',...
    'TOT_FMASS','TOT_POWDENS','BURN_POWER','BURN_GENRATE','BURN_FISSRATE',...
    'BURN_ABSRATE','BURN_FLUX','BURN_FMASS','BURN_POWDENS','BURN_VOLUME',...
    'ANA_PROMPT_LIFETIME','IMPL_PROMPT_LIFETIME','ANA_REPROD_TIME',...
    'IMPL_REPROD_TIME','DELAYED_EMTIME','SIX_FF_ETA','SIX_FF_F','SIX_FF_P',...
    'SIX_FF_EPSILON','SIX_FF_LF','SIX_FF_LT','SIX_FF_KINF','SIX_FF_KEFF',...
    'USE_DELNU','PRECURSOR_GROUPS','BETA_EFF','BETA_ZERO','DECAY_CONSTANT',...
    'GC_UNI','GC_SYM','GC_NE','GC_BOUNDS','GC_REMXS_INCLUDE_MULT',...
    'FLUX','LEAK','TOTXS','FISSXS','CAPTXS','ABSXS','RABSXS','ELAXS','INELAXS',...
    'SCATTXS','SCATTPRODXS','N2NXS','REMXS','NUBAR','NSF','RECIPVEL','FISSE',...
    'CHI','CHIP','CHID','GTRANSFP','GTRANSFXS','GPRODP','GPRODXS','DIFFAREA',...
    'DIFFCOEF','TRANSPXS','MUBAR','MAT_BUCKLING','LEAK_DIFFCOEF','SCATT0',...
    'SCATT1','SCATT2','SCATT3','SCATT4','SCATT5','P1_TRANSPXS','P1_DIFFCOEF',...
    'P1_MUBAR','B1_KINF','B1_BUCKLING','B1_FLUX','B1_TOTXS','B1_NSF','B1_FISSXS',...
    'B1_CHI','B1_ABSXS','B1_RABSXS','B1_REMXS','B1_DIFFCOEF','B1_SCATTXS',...
    'B1_SCATTPRODXS','ADFS','ADFC'};

%% 5% checks:

% This goes through all variables to check to see if there is anything that
% is within a 5% difference of each other.
%
% These differences will be printed in an output file.

% NOTES:
% Check if variable is zero (do not divide by it).

if man ~= 1
    cd(prefix)
end

work_dir = pwd;

% Read in variables:
for i = 1:length(fold)
    
    % Change folder:
    cd(fold{i})
    cur_dir = pwd;
    
    % Clear variables:
    clear idx
    
    % Load new variables:
    s_res = Serp_search_res();
    eval(s_res{1})
    
    % Save variables:
    for j = 1:length(VAR)
        if exist(VAR{j},'var')
            s_var = [VAR{j} '_' num2str(i) ' = ' VAR{j} ';'];
            eval(s_var)
        else
            % Print what is missing:
            cd(data_dir)
            mis_string = ['diary ' mis_fil];
            eval(mis_string)
            
            fprintf('%s is missing. \n',VAR{j})
            
            diary off
            cd(cur_dir)
        end
    end
    
    cd(work_dir)
end

% Compare variables:

% Start file:

cd(data_dir)

fid=fopen(err_fil,'wt');
loc = 1;

x = {'Variable','Burn_step','Index','Folder','Error','Value','Rel_Err','Value_Compared','Rel_Err'};

if man ~= 1
    fprintf(fid,'Folder,%s\n',prefix);
end

fprintf(fid,'Error_tolerance,%f\n',error_tol);
fprintf(fid,'%s,',x{loc,1:end-1});
fprintf(fid,'%s\n',x{end});

for i = 1:length(VAR) % Loop through variables.
    
    if exist(VAR{i},'var')
        % Set comparing variable:
        %  For man 1,2 this will be the first directory...
        %  For man 3 this will be the last directory...
        
        s_temp = ['t1 =' VAR{i} '_' num2str(1) ';'];
        eval(s_temp)
        
        for j = 2:length(fold) % Loop through runs.
            
            % Set temporary variables:
            
            s_temp = ['t2 =' VAR{i} '_' num2str(j) ';'];
            eval(s_temp)
            
            N1 = size(t1,2);
            N2 = size(t2,2);
            
            B1 = size(t1,1);
            B2 = size(t2,1);
            
            % Check variables are same length:
            if N1 == N2 && B1 == B2
                
                for m = 1:B1 % Loop through burnup steps.
                    %                     fprintf(fid,'For bunrup step: %i \n',m);
                    
                    for k = 1:N1 % Loop through index of variable.
                        
                        if rem(k,2) == 1
                            t1_n = t1(m,k);
                            t2_n = t2(m,k);
                            
                            % Check variable is zero:
                            if t1_n ~= 0 
                                % Advance location in file:
                                loc = loc + 1;
                                
                                % Find error:
                                abs_err = (t1_n-t2_n)/t1_n;
                                
                                % If error greater than the desired tolerance, print.
                                if abs_err > error_tol
                                    
                                    % Seperate those that have relative errors
                                    % to plot and print to error file.
                                    if N1 > 1
                                        fprintf(fid,'%s,%i,%i,%s,%f,%e,%f,%e,%f\n',VAR{i},m,k,fold{j},abs_err,t1_n,t1(m,k+1),t2_n,t2(m,k+1));
                                    else
                                        fprintf(fid,'%s,%i,%i,%s,%f,%e,,%e\n',VAR{i},m,k,fold{j},abs_err,t1_n,t2_n);
                                    end
                                end
                            end
                            
                        else
                            ...
                        end
                    end
                end
            end
        end
    end
end

cd(top_dir)

fclose(fid);
