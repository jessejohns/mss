function output = Serp_ext_mat(prefix, man,opt)
%% Serp_ext_mat(prefix, man, opt)
%
%  This script extracts material information.
%
% Written by:
%    Jesse Johns
%    Texas A&M University
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
%   opt.
%     pin = must be a string.  This allows a specific pin to be used.  If
%           this variable is used, .matname and .rad must also be used.
%     var_use = variable to be extracted.
%     time_use =
%     matname = this is the name of the MAT_'matname' indentifier, which is
%               the name of the burned material in the pin.
%     rad = for self-shielding calculations, this must be specified.
%           Defaults to = 1.
%
% - Output variables: - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% output.burn = Burn
% output.data = a_dense
% output.name = NAMES
% output.zaid = zaid
% output.fold = fold
%
%% Example:
%
%  If plotting a pin:
%     Gd
%  opt.pin = '52';
%  opt.matname = 'UO2Gd';
%  opt.rad = 1;

%% Checks

if isfield(opt,'var_use') == 0
    opt.var_use = 'TOT_ADENS';
end

if isfield(opt,'time_use') == 0
    opt.time_use = 'BU';
end

if isfield(opt,'pin') == 1
    
    if isfield(opt,'matname') == 0
        error('Must define opt.matname if opt.pin is used \n')
    end
    
    if isfield(opt,'rad') == 0
        opt.rad = 1;
    end
    
end

%% Start script:

% Initialize:
mat = 0;
m_end = 1;
count = 0;
ind = 0;

% Redefine:

if isfield(opt,'pin') == 1
    opt.var_use = ['MAT_' opt.matname 'p' opt.pin 'r' num2str(opt.rad) '_ADENS'];
    opt.time_use = ['MAT_' opt.matname 'p' opt.pin 'r' num2str(opt.rad) '_BURNUP'];
end


%% Loop for folders:

top_dir = pwd;

if man == 2;
    fold = build_dir(prefix);
    cd(prefix)
elseif man == 3;
    fold = build_dir(prefix, 1);
    cd(prefix)
elseif man == 1;
    fold = {prefix};
    fold = fold{1};
end

%% Read data

work_dir = pwd;

for i = 1:length(fold);
    
    dep_file = Serp_search_dep(fold{i});
    
    cd(fold{i})
    eval(dep_file{1});
    cd(work_dir)
    
    % Save data
    zaid{i} = ZAI;
    name{i} = NAMES;
    
    k_string = ['adens{' num2str(i) '} = ' opt.var_use ';'];
    eval(k_string);
    
    b_string = ['Burn{' num2str(i) '} =' opt.time_use ';'];
    eval(b_string);
    
end

%% Loop for mats
%

while m_end > 0
    
    mat = mat+1;
    
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
    
    % Format output
    %  TODO: add check for names:
    for i = 1:length(fold)
        a_dense{mat,i} = adens{i}(mat,:);
    end
    
    % Set break point:
    if strcmp(name{i}(mat,:),'total           ') == 1
        break
    end
    
end

cd(top_dir)

%% Set ouput variables:
output.burn = Burn;
output.data = a_dense;
output.name = NAMES;
output.zaid = zaid;
output.fold = fold;

end
