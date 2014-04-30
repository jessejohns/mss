function Serp_code_test(work_dir,type)
%
% This function runs through many tests for Serpent. This tests will be
% compared to a base soluation.  This is to verify compilation and changes
% in source code do not affect results.
%
% Major discepencies will be indicated by the case number and a output file
% will be printed in the
%
% The base solution will be from Serpent 1.1.17, the latest versions
% currently are:
%   
%   Serpent 1.1.17
%   Serpent 2.1.6
%
% The followings cases are compared:
G_set = {
    'Assembly'
    'Other'
    };
%
% Is the directory exists, this script will skip it.
%
% The user needs to direct the code to the proper files.
%
%% Notes:
% This requires "Serp_stat_test.m"
%
% The user extracts all the testing files.
%   Each directory consists of a "Test" directory and "Bench" directoy. The
%   "Test" directory, which will be the directory in which to run the file.
%
% There are two types:
%   Inherently, there are different options for Serpent 1 and 2.  The main
%   difference being in the gamma transport.  This script will
%   automatically neglect the tests that do not apply.
%
%
%% TODO
%
%  Detector comparisons.
%  Benchmark problems?

%% Script:

cur_dir = pwd;

cd(work_dir)

cont = 1;

for i = 1:length(G_set)
    
    if exist(G_set{i},'dir')
        cd(G_set{i})
    end
    
    cd Test    
    
    %% Run input file
    if type == 1
        !sss input_file
    elseif type == 2
        !sss2 input_file
    end
    
    %% Run checks:
    
end

cd(cur_dir)