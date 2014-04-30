function output = Serp_plot_his(prefix,man,opt)
%%
%  This scripts plots history output from Serpent 2:
%     set his 1
%
%  NEED TO DOCUMENT VARIABLES!
%  Change this is "extract" function and make another for plotting.
%
% prefix is the folder prefix, and the input file is just that.
%   The input file name has to be the same for all models.
%
% if man = 0, the prefix is a prefix for the folder...
%             so, prefix = 'run_' if we are looking through run_01, run_02,
%             but man = 2 makes this kind of pointles...
%
% if man = 1, then prefix will be a string of folders using {}.
%
% if man = 2, the prefix will be the main directory and MATLAB will look
%             through all the folders in that directory.
%
% if man = 3, same as 2 but flips the folders... just helps with plotting.
%
% if opt.s > 0, will save plots and data
%        s < 0, will just save data
%        s = 0, will not save anything
%
%    opt.base = 1; This will include a "base" case with a seperate
%       directory, so you also need:
%
%       .base_dir

%% Initialize flags and counters:
done = 0;

import mongoose.*

%% Check variables:
%   This checks if variable exist and sets to default if they do not.
if isfield(opt,'save_dir') == 0
    opt.save_dir = pwd;
end

if isfield(opt,'s') == 0
    opt.s = 0;
end

if isfield(opt,'plot') == 0
    opt.plot = 1;
end

if isfield(opt,'base') == 0
    opt.base = 0;
end

%% Build directory information

if man == 2;
    fold = build_dir(prefix);
    
elseif man == 3;
    fold = build_dir(prefix, 1);
    
elseif man == 1;
    fold = {prefix};
    fold = fold{1};
    
elseif man == 0;
    error('man == 0 is no longer available.')
end

%% Run loop
while done == 0;
    
    % Change into directory for man = 2,3...
    top_dir = pwd;
    
    if man ~= 1
        cd(prefix);
    end
    
    % Set data variables:
    for i = 1:length(fold);
        
        cur_dir = pwd;
        
        % Read data
        
        his_file = Serp_search_his(fold{i});
        res_file = Serp_search_res(fold{i});
        cd(fold{i})
        eval(his_file{1});
        eval(res_file{1});
        cd(cur_dir)
        
        % Organize data
        G{i} = HIS_IMP_KEFF;
        H{i} = HIS_ENTR_SWG;
        L{i} = 1:1:length(HIS_IMP_KEFF);
        K{i,1} = TOT_CPU_TIME;
        K{i,2} = MEMSIZE;
        K{i,3} = IMP_KEFF;
        
        clear idx
        
    end
    
    
    %% Make legend
    
    for i = 1:length(fold)
        
        f_split = regexp(fold{i},'_','split');
        if length(f_split) == 2
            leg{i} = [f_split{1} ' ' f_split{2}];
        else
            leg{i} = fold{i};
        end
    end
    
    %% Plotting
    
    if opt.plot == 1
        % List of lines styles:
        if length(fold) > 10
            error('Number of folders too great, add more line specifications.')
        else
            line_style = {'b-','r--','k--','b--','g--','m--','r-.','b-.','k-.','m-.'};
        end
        
        % For keff:
        for j = 2:4
            figure; clf
            xlabel('step')
            
            if j == 2
                ylabel('Current iterate K_e_f_f')
            elseif j == 3
                ylabel('Average K_e_f_f')
            else
                ylabel('STD of K_e_f_f')
            end
            
            for i = 1:length(fold);
                hold on;
                plot(L{i},G{i}(:,j),line_style{i},'LineWidth',2); %#ok<*USENS>
            end
            
            legend(leg,'Location','EastOutside')
            prettyPlot(gcf)
            
            if j == 3
                for i = 1:length(fold);
                    boundedline(L{i},G{i}(:,j),zeros(size(G{i}(:,j)))+G{i}(:,4),line_style{i},'alpha')
                end
            end
            
        end
        
        % For entropy:
        for j = [3 6 9]
            figure; clf
            xlabel('step')
            
            if j == 3
                ylabel('Entropy for system')
            elseif j == 6
                ylabel('Entropy in X')
            else
                ylabel('Entropy in Y')
            end
            
            for i = 1:length(fold);
                hold on;
                plot(L{i},H{i}(:,j),line_style{i},'LineWidth',2); %#ok<*USENS>
            end
            
            legend(leg,'Location','EastOutside')
            prettyPlot(gcf)
        end
        

    end

    done = 1;
    
end

cd(top_dir)

%% Finalize outputs:

output.G = G;
output.L = L;
output.H = H;
output.leg = leg;
output.K = K;


end
