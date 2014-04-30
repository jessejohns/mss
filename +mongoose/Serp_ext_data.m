function output = Serp_ext_data(prefix,man,opt)
%% output = Serp_ext_data(prefix,man,opt)
%
%  This function collects data from a Serpent result file for whatever data
%  variable is of interest.  It can collect directory information
%  automatically and builds a cell array with that data.  This is to ensure
%  that data that is different length can be easily collected.
%
%  Written by:
%    Jesse Johns
%    Texas a&M University
%    jesse.m.johns@gmail.com
%
% - Input variables: - - - - - - - - - - - - - - - - - - - - - - - - - - 
%
% prefix - this is a cell of strings that contains directory information
%          based on the needs of the 'man' input.
%
% if man = 1, then prefix will be a string of folders using {}.
%
% if man = 2, the prefix will be the main directory and MATLAB will look
%             through all the folders in that directory.
%
% if man = 3, same as 2 but flips the folders... just helps with plotting.
%
% opt.   - this is a structure with the following inputs:
%     data_type =
%     time_type =
%
% - Output variables: - - - - - - - - - - - - - - - - - - - - - - - - - - 
% 
% output. - this is a structure with the following outputs:
%     G =
%     data =
%     burn = 
%     err_r =
%     err_a =

%% Initialize flags and counters:
done = 0;

%% Check variables:
if isfield(opt,'data_type') == 0
    opt.data_type = 'ABS_KEFF';
end

if isfield(opt,'time_type') == 0
    opt.time_type = 'BURN_DAYS';
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
    
    % Change into directory for man = 2,3...
    top_dir = pwd;
    
    if man ~= 1
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
    
    %% Error:
    %
    %  The reference is by default the first entry in the directory list.
    
    % Calculate errors:
    for i = 2:length(fold)
        if length(burn{1}) == length(burn{i})
            
            err_a{i-1} = (data{i} - data{1});
            err_r{i-1} = (data{i} - data{1})./data{i};
            
        end
    end
    
end

cd(top_dir)

%% Finalize outputs:

output.G = G;
output.data = data;
output.burn = burn;

if exist('err_r','var')
    output.err_r = err_r;
    output.err_a = err_a;
end

end