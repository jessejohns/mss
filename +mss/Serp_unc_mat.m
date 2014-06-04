function [G_mean G_std] = Serp_unc_mat(prefix, man)
%% Description
%
%   This function plots the isotopical changes as a function of burnup.
%
%%  Inputs:
%
%   prefix - carries different meanings.
%
%   man = 0 for automatic directory determination base on prefix.
%
%   s  = 1 to save images in .png format
%      = 2 to save images in .pdf
%      = 0 to be prompted to wait/save
%     ~= 0 there will not be any waiting for user input.
%          ie: set to 3 to automatically generate G_mean/std.
%
%   save_dir, directory to save data.
%
%   data = [a b c d]
%      a, 1 = plot
%      b, data set from Serp_bench_data.m
%      c. secondary data set
%      d, >0 will save vector for the last in a file named after the
%         directory listing
%   keff > 0 will plot keff on a seperate axis.
%
%   lege, allows for manually overriding the legend displayer.
%         - defaults to using the directory list.
%
%% Checks

if exist('man','var') == 0
    error(' "man" input required.')
end

%% Options:

var_use = 'TOT_MASS';

%% Start script:

% Initialize:
mat = 0;
m_end = 1;

%% Loop for folders:

top_dir = pwd;

if man == 2;
    fold = build_dir(prefix);
    cd(prefix)
elseif man == 3;
    fold = build_dir(prefix, 1);
    
elseif man == 1;
    fold = {prefix};
    fold = fold{1};
end

%% Loop for mats

work_dir = pwd;

while m_end > 0
    
    mat = mat+1;
    
    %% Read data
    
    for i = 1:length(fold);
        
        clear idx BURN_DAYS ABS_KEFF
        
        % Find depletion file:
        dep_file = Serp_search_dep(fold{i});
        
        % Swap to directory:
        cd(fold{i})
        eval(dep_file{1});
        cd(work_dir)
        
        if i == 1
            name = NAMES(mat,:);
            burn = BU;
            zaid = ZAI;
        end
        
        if length(burn) == length(BU)
            
            mat_2 = 0;
            done = 0;
            
            while done == 0
                
                mat_2 = mat_2 + 1;
                
                if mat_2 <= length(ZAI)
                    
                    if ZAI(mat_2) == zaid(mat)
                        
                        dat_string = ['dat_burn(i,:) = ' var_use '(mat_2,:);'];
                        eval(dat_string)
                        
                        break
                        
                    end
                    
                else
                    fprintf('Ignore this plot - data does not exist for all inputs.\n')
                    break
                end
            end
            
        else
            error('The burn steps are not equal. \n  This script requires that they are.')
        end
        
    end
    
    %% Uncertainties:
    
    % List of lines styles:
    
    figure(1); clf; hold on;
    
    % Find mean and std for each burnup step:
    
    dat_mean = zeros(1,length(burn));
    dat_std = dat_mean;
    
    for i = 1:length(burn);
        
        dat_mean(i) = mean(dat_burn(:,i));
        dat_std(i) = std(dat_burn(:,i));
        
    end
    
    % Save mean and std for last burnup step:
    
    G_mean(mat) = mean(dat_burn(:,end));
    G_std(mat) = std(dat_burn(:,end));
    
    % Set break point:
    if strcmp(name,'total           ') == 1
        break
    end
    
    clc
    
end

cd(top_dir)
end
