function dep_file = Serp_search_dep(direct)
%%

%   This function will serach the directory to find a Serpent result file
%   and outputs the name.  This function finds the first result file and
%   then breaks.

%% Script
top_dir = pwd;

if exist('direct','var')
    cd(direct)
end

%  Build directory inventory list:
d_list = dir();

%  Sort list and find:
i = 2;

while i < length(d_list)
    i = i + 1;
    
    if strfind(d_list(i).name,'_dep') > 1
        dep_file = d_list(i).name;
        break
    end
    
end

%  Break out the ".m";
if exist('dep_file','var')
    sp_file = regexp(dep_file, '\.', 'split');
    dep_file = sp_file(1);
else
    dep_file = {'0'};
end

cd(top_dir)
