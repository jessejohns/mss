function det_file = Serp_search_det(direct)
%%
%
%   This function will serach the directory to find Serpent detector files.
%   It accounts for the fact that burnup calculations will create many
%   detector files.
%

%% Script
top_dir = pwd;

if exist('direct','var')
    cd(direct)
end

%  Build directory inventory list:
d_list = dir();

%  Sort list and find:
i = 2;
j = 0;

while i < length(d_list)
    i = i + 1;
    
    if strfind(d_list(i).name,'_det')
        j = j+1;
        det_file{j} = d_list(i).name;
    end
    
end

N = j;

%  Break out the ".m";
for i = 1:N
    if exist('det_file','var')
        sp_file = regexp(det_file{i}, '\.', 'split');
        det_file{i} = sp_file(1);
    else
        error('Could not find detector file.')
    end
end

%  Organize file listing:
%    This is performed like this without a integer list in the event that a
%    detector file is missing.
%
for i = 1:N
    split = regexp(det_file{i}, 'det', 'split');
    idx{i}= str2num(cell2mat(split{1}(2)));
    name{i} = det_file{i};
end

idx_sort = sort(cell2mat(idx));

for i = 1:N
    for j = 1:N
        if cell2mat(idx(j)) == idx_sort(i);
            det_file{i} = name{j};
        end
    end
end

cd(top_dir)