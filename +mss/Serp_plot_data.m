function output = Serp_plot_data(prefix,man,opt)
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
count = 0;
done = 0;
count_run = 0;
ind = 0;

import mss.*

%% Check variables:
%   This checks if variable exist and sets to default if they do not.
if isfield(opt,'save_dir') == 0
    opt.save_dir = pwd;
end

if isfield(opt,'s') == 0
    opt.s = 0;
end

if isfield(opt,'data_type') == 0
    opt.data_type = 'ABS_KEFF';
end

if isfield(opt,'time_type') == 0
    opt.time_type = 'BURN_DAYS';
end

if isfield(opt,'plot') == 0
    opt.plot = 1;
end

if isfield(opt,'base') == 0
    opt.base = 0;
end

%% Labels:
%   These are added as needed, just to make the plot look good.

if strcmp(opt.data_type,'ABS_KEFF');
    yaxis_label = 'k_e_f_f';
elseif strcmp(opt.data_type,'BETA_EFF');
    yaxis_label = 'Beta_e_f_f';
else
    yaxis_label = opt.data_type;
end

if strcmp(opt.time_type,'BURN_DAYS');
    xaxis_label = 'Time [days]';
elseif strcmp(opt.time_type,'BURNUP');
    xaxis_label = 'Burnup [MWd/kg]';
else
    xaxis_label = opt.time_type;
end


%% Build directory information

if man == 2;
    fold = build_dir(prefix);
    
elseif man == 3;
    fold = build_dir(prefix, 1);
    
elseif man == 1;
    fold = {prefix};
    fold = fold{1};
end

%% Run loop
while done == 0;
    
    % This runs through folders of name Run_01, etc... and then only allows
    % for 10 to be displayed at a time.  This is for optimization cases
    % where there might be hundreds of cases to display.
    if man == 0
        clear fold
        
        while count < 10
            ind = ind + 1;
            
            check = [prefix num2str(ind)];
            f_find = exist(check,'dir');
            
            if f_find > 0 && count < 10
                count = count + 1;
                fold{count} = check;
            elseif ind == 1000 || f_find == 0;
                done = 1;
                break
            end
        end
        
        count = 0;
    end
    
    % Change into directory for man = 2,3...
    top_dir = pwd;
    
    if man ~= 1 && man ~= 0
        cd(prefix);
    end
    
    % Set data variables:
    for i = 1:length(fold);
        
        clear idx BURN_DAYS ABS_KEFF BURNUP RUNNING_TIME MEMSIZE
        cur_dir = pwd;
        
        % Read data
        
        res_file = Serp_search_res(fold{i});
        
        cd(fold{i})
        eval(res_file{1});
        cd(cur_dir)
        
        % New data array:
        %
        %  Use of structure to contain data with varying lengths:
        
        k_string = ['data{' num2str(i) '} = ' opt.data_type '(:,1);'];
        b_string = ['burn{' num2str(i) '} = ' opt.time_type '(:,1);'];
        eval(k_string);
        eval(b_string);
        
        % More data
        
        G(i,1) = ABS_KEFF(end,1); %#ok<*COLND> % Final Keff
        G(i,2) = ABS_KEFF(end,2); % Final Keff std
        G(i,4) = RUNNING_TIME(end,1); % running time
        G(i,3) = MEMSIZE(end,1); % memory used
        
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
        
        % As a function of years:
        figure; clf
        xlabel(xaxis_label);
        ylabel(yaxis_label,'Interpreter', 'none');
        
        for i = 1:length(fold);
            hold on;
            plot(burn{i},data{i},line_style{i},'LineWidth',2); %#ok<*USENS>
        end
        
        legend(leg,'Location','EastOutside')
        prettyPlot(gcf)
        
    end
    
    %% Error plot:
    %
    %  The reference is by default the first entry in the directory list.
%     
%     if opt.plot == 1
%         figure; clf
%         hold on
%     end
%     
%     % Calculate errors:
%     for i = 2:length(fold)
%         if length(burn{1}) == length(burn{i})
%             
%             err_a{i-1} = (data{i} - data{1});
%             err_r{i-1} = (data{i} - data{1})./data{i};
%             
%             if opt.plot == 1
%                 plot(burn{i},err_r{i-1},line_style{i-1})
%             end
%         end
%         
%     end
%     
%     if opt.plot == 1
%         legend(leg(2:end),'Location','EastOutside')
%         xlabel(xaxis_label);
%         ylabel('Relative Error')
%         prettyPlot(gcf)
%     end
    
    %% Dialog
    if man == 0
        clc
        count_run = count_run + 1;
        
        if count_run > 9
            input('\n Hit enter when done viewing/saving plot.\n')
        end
        
        if count_run == length(fold) && man == 0
            done = 1;
        end
        
    elseif man ~= 0
        done = 1;
    end
    
end

if opt.s ~= 0
    cd(save_dir)
    
    if exist('Data','dir') == 0
        mkdir Data
    end
    
    cd Data
end

num_fig = (findobj('Type','figure'));

if opt.s  > 0
    
    for i = 1:num_fig
        saveplot(pwd,[prefix '_' num2str(i)],opt.s)
    end
    
    dlmwrite([prefix '_Data.csv'],G,'delimiter',',','precision','%.5f')
    
elseif opt.s < 0
    dlmwrite([prefix '_Data.csv'],G,'delimiter',',','precision','%.5f')
end

cd(top_dir)

%% Finalize outputs:

output.G = G;
output.leg = leg;
output.data = data;
output.burn = burn;

if exist('err_r','var')
    output.err_r = err_r;
    output.err_a = err_a;
end

end
