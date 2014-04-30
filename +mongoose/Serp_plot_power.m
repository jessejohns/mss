function Serp_plot_power(prefix,man,s,save_dir)
% NEED TO DOCUMENT!
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
% if s > 0, will save plots and data
%    s < 0, will just save data
%    s = 0, will not save anything
%
%% TODO
%
%  Plot distributions normally for single input.
%
%  If multiple, plot a "mean", "std"
%
%  Add option to simply run through and print plots... 
%
%  Add burnup plotting option.
%
%% Initialize

NAN = 0;
INF = 0;
count = 0;
done = 0;
count_run = 0;
ind = 0;

if exist('save_dir','var') == 0
    save_dir = pwd;
end

if exist('s','var') == 0
    s = 0;
end

if exist('data_type','var') == 0
    data_type = 'ABS_KEFF';
end

%% Labels:

if strcmp(data_type,'ABS_KEFF');
    yaxis_label = 'k_e_f_f';
elseif strcmp(data_type,'BETA_EFF');
    yaxis_label = 'Beta_e_f_f';
else
    yaxis_label = data_type;
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
        %  These are like this instead of arrays so they can handel vectors
        %  of different sizes.

        k_string = ['Keff_data_' num2str(i) '(:,1) = ' data_type '(:,1);'];
        b_string = ['Burn_days_' num2str(i) '(:,1) = BURN_DAYS(:,1);'];
        eval(k_string);
        eval(b_string);
        
        b_string = ['Burnup_' num2str(i) '(:,1) = BURNUP(:,1);'];
        eval(b_string);
        
        % More data
        %   Ignore these errors... MATLAB can't see into my strings. :-)
        
        G(i,1) = ABS_KEFF(end,1); %#ok<*COLND> % Final Keff
        G(i,2) = ABS_KEFF(end,2); % Final Keff std
        G(i,4) = RUNNING_TIME(end,1); % running time
        G(i,3) = MEMSIZE(end,1); % memory used
        
        % Extra entry:
        %     l_string = ['Loss_' num2str(i) '(:,1) = TOT_LOSSRATE(:,1);'];
        %     eval(l_string);
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
    
    % List of lines styles:
    if length(fold) > 10
        error('Number of folders too great, add more line specifications.')
    else
        line_style = {'b-','r--','k--','b--','g--','m--','r-.','b-.','k-.','m-.'};
    end
    
    % As a function of years:
    figure(1);
    clf
    xlabel('Years');
    ylabel(yaxis_label,'Interpreter', 'none');
    
    for i = 1:length(fold);
        hold on;
        p_string = ['plot(Burn_days_' num2str(i) '(:,1)/365, Keff_data_' num2str(i) '(:,1),line_style{i});'];
        eval(p_string);
    end
    
    legend(leg,'Location','EastOutside')
    grid on;
    whitebg('white')
    set(gcf,'Color',[1 1 1])
    set(gcf,'Position',[118   481   719   441])
    
    % Aa a function of burnup:
    figure(2)
    clf
    xlabel('Burnup (MWd/kg)');
    ylabel(yaxis_label,'Interpreter', 'none');
    
    for i = 1:length(fold);
        figure(2);
        hold on;
        p_string = ['plot(Burnup_' num2str(i) '(:,1), Keff_data_' num2str(i) '(:,1),line_style{i});'];
        eval(p_string);
    end
    
    legend(leg,'Location','EastOutside')
    grid on;
    whitebg('white')
    set(gcf,'Color',[1 1 1])
    set(gcf,'Position',[118   481   719   441])
    
    %% Error plot:
    %
    %  The reference is by default the first entry in the directory list.
    
    % Change and clear figure
    
    figure(3)
    clf
    hold on
    
    if strcmp(prefix,'Stepping') == 0
        
        for i = 2:length(fold);
            % Find beta:
            beff = BETA_EFF(:,1);
            
            %   Correct beta to have the previous beta_eff for times of
            %   shutdown.  This will obviously fail if the shutdown period is
            %   in the beginning.
            
            for j = 1:length(beff)
                if beff(j) < 0.0001
                    beff(j) = beff(j-1);
                end
            end
            
            % Determine error:
            e_string = ['err_c_' num2str(i) '(:,1) = (Keff_data_' num2str(i) '(:,1)-Keff_data_1(:,1))./beff*100'];
            eval(e_string);
            
            % Plot:
            ep_string = ['plot(Burnup_' num2str(i) '(:,1), err_c_' num2str(i) '(:,1),line_style{i});'];
            eval(ep_string)
        end
        
        legend(leg(2:end),'Location','EastOutside')
        xlabel('Burnup (MWd/kg)');
        ylabel('Cents')
        grid on;
        whitebg('white')
        set(gcf,'Color',[1 1 1])
        set(gcf,'Position',[118   481   719   441])
    end
    
    %% Dialog
    clc
    
    count_run = count_run + 1;
    
    if count_run > 9
        input('\n Hit enter when done viewing/saving plot.\n')
    end
    
    if count_run == length(fold) && man == 0
        done = 1;
    elseif man ~= 0
        done = 1;
    end
    
end

if exist('s','var')
    ...
else
s = 0;
end

if s == 1
    
    cd(save_dir)
    if exist('Data','dir')
        ...
    else
    mkdir Data
    end
    
    cd Data
    set(i, 'PaperPosition', [0 0 5 3.5]);
        set(i, 'PaperSize', [5 3.5]);
    saveas(1,[prefix '_keff_vs_time'],'png')
    saveas(2,[prefix '_keff_vs_BU'],'png')
    saveas(3,[prefix '_err_vs_time'],'png')
    
elseif s == 2
    
    % Set figures to be pdfable...
    for i = 1:3
        set(i, 'PaperPosition', [0 0 6 3]);
        set(i, 'PaperSize', [6 3]);
    end
    
    saveas(1,[prefix '_keff_vs_time'],'epsc')
    saveas(2,[prefix '_keff_vs_BU'],'epsc')
    saveas(3,[prefix '_err_vs_time'],'epsc')
    
    dlmwrite([prefix '_Data.csv'],G,'delimiter',',','precision','%.5f')
    
elseif s < 0
    dlmwrite([prefix '_Data.csv'],G,'delimiter',',','precision','%.5f')
end

cd(top_dir)
end