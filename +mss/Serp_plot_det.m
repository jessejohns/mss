function output = Serp_plot_det(prefix,man,opt)
%% output = Serp_plot_det(prefix,man,opt)
%
%  This function plots detectors from Serpent 2 outputs.
%
%
%% Inputs
%
%  prefix = case string when depends on the man input:
%
% if man = 0, the prefix is a prefix for the folder...
%             so, prefix = 'run_' if we are looking through run_01, run_02,
%             but man = 2 makes this kind of pointless...
%
% if man = 1, then prefix will be a string of folders using {}.
%
% if man = 2, the prefix will be the main directory and MATLAB will look
%             through all the folders in that directory.
%
% if man = 3, same as 2 but flips the folders... just helps with plotting
%
%  opt.     - Option structure
%      err  - This determines whether an absolute (1) or relative (2) error
%             plot should be generated with the detectors.  This is a
%             single value is applied to all or a vector if only certain
%             error plots are to be generated.
%
%% Testing:
close all; clear; clc
direct = '/home/jesse/Simulations/PhD/Core/Tests/';
% direct = 'C:\Sync\Simulations-PhD\Lattice';
% prefix = 'SourceConvergence';
prefix = {'Symmetry/Usym_2'};
man = 1;
opt.err = [1 0];
cd(direct);

%% Check inputs:
%
if isfield(opt,'err') == 0
    opt.err = 0;
end

import mongoose.*

%% Set up directory:
if man == 2;
    fold = build_dir(prefix);
    
elseif man == 3;
    fold = build_dir(prefix, 1);
    
elseif man == 1;
    fold = {prefix};
    fold = fold{1};
elseif man == 0;
    error('This option has been removed as it is obsolete.')
end

%% Script:
if man ~= 1
    cd(prefix);
end

done = 0;

% Loop through folders:
for i = 1:length(fold)
    
    cd(fold{i})
    
    % Find all detectors files:
    det_file = Serp_search_det('.');
    
    for j = 1:length(det_file)
        
        res = Serp_ext_det(cell2mat(det_file{j}));
        
        % Check length for error plots:
        %     if length(opt.err) == 1
        %         opt.err = ones(length(det_file),1)*opt.err;
        %     elseif length(opt.err) ~= length(det_file)
        %         error('Number of detectors is not equal to the opt.err input. \n')
        %     end
        
        if res.flag{j} == 2
            
            semilogx(res.array{:,1},res.value{:,1});
            
        elseif res.flag{j} == 3
            
            for i = 1:length(res.value)
                if max(max(res.value{1,1})) ~= 0
                    figure
                    surf(res.array{i,1},res.array{i,2},res.value{i,1})
                    view(0,90)
                    
                    shading flat
                    colorbar
                    
                    figure
                    surf(res.array{i,1},res.array{i,2},res.err{i,1})
                    view(0,90)
                    
                    shading flat
                    colorbar
                end
            end
        end
        
        clear res
    end
    
    cd ..
    
end
