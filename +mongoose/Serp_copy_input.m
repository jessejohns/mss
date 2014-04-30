function Serp_copy_input(main_dir,sea_dir)
%  Serp_copy_input
%
%  This function goes through a directory to fine the input file that
%  appends a result file then copies is to the specified directory.
%
%  Written by:
%     Jesse Johns
%     Texas A&M University
%

%% Testing variables:
% main_dir = '/home/jesse/Simulations/Serpent1/Bench_Test/Criticality';
% sea_dir = '/home/jesse/Simulations/Serpent1/Bench_Test/Criticality/Crit_01';

%% Notes

%% Begin script

% Search directory

d_list = dir(sea_dir);
N = length(d_list);

for i = 3:N
    f_list{i-2} = d_list(i).name;
    
    test = strfind(f_list{i-2},'_res.m');
    
    if test > 0
        FOUND = i-2;
    end
end

% Copy to main directory:

if exist('FOUND','var')   
    split_line = regexp(f_list{FOUND},'_','split');
    in_file = split_line{1};
       
    copyfile([sea_dir '/' in_file],[main_dir '/' in_file])
else
    error('Could not find input file in the specified directory: \n %s',sea_dir)
end

