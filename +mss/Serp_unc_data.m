function [dat_mean dat_std burn] = Serp_unc_data(prefix, man, opt)
%% Description
%
%   This function plots the uncertainty associated with keff as a function
%   of burnup.
%
%   Make sure that iterative methods and non-iterative methods are tested
%   seperately.
%
%   Alpha mode does NOT change abs_keff.

%%  Inputs:
%
%   prefix - carries different meanings.
%
%   man = 0 for automatic directory determination base on prefix.
%
%   The following inputs are data structures for the container:
% 
% opt.
%
%   time = 1 BURNUP (default)
%          2 DAYS
%
%   keff > 0 will plot keff on a seperate axis.
%
%
%% Checks

if exist('man','var') == 0
    error(' "man" input required.')
end

if isfield(opt,'var_use') == 0
    opt.var_use = 'ABS_KEFF';
end

if isfield(opt,'time') == 0
    opt.time = 1;
end

%% Start script:

% Loop for folders:

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

work_dir = pwd;

%% Read data

for i = 1:length(fold);
    
    clear idx BURN_DAYS ABS_KEFF BURNUP BETA_EFF
    
    % Find depletion file:
    res_file = Serp_search_res(fold{i});
    
    % Swap to directory:
    cd(fold{i})
    eval(res_file{1});
    cd(work_dir)
    
    % This is a check to ensure the time steps are the same.
    if opt.time == 1
        
        if i == 1
            burn = BURNUP;
        end
        
        if length(burn) == length(BURNUP)
            
            dat_string = ['dat_burn(i,:) = ' opt.var_use '(:,1);'];
            eval(dat_string)
            
        else
            error('The burn steps are not equal. \n  This script requires that they are.')
        end
        
    else
        
        if i == 1
            burn = BURN_DAYS;
        end
        
        if length(burn) == length(BURN_DAYS)
            
            dat_string = ['dat_burn(i,:) = ' opt.var_use '(:,1);'];
            eval(dat_string)
            
        else
            error('The burn steps are not equal. \n  This script requires that they are.')
        end
        
    end
    
end

%% Uncertainties:

dat_mean = zeros(1,length(burn));
dat_std = dat_mean;

for i = 1:length(burn);
    
    dat_mean(i) = mean(dat_burn(:,i));
    dat_std(i) = std(dat_burn(:,i));
    
end

fprintf('\n FINAL Keff: \t%f +/- %5.4e \n',dat_mean(end),dat_std(end))

cd(top_dir)

end
