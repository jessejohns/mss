function Serp_check_conv
%
%  This script reads data from various runs to compare the convergence of
%  various parameters and the maximum detector errors.
%
%
%% TODO 
%  Add burnup support for parameters and detectors.
%    It will very very interesting to see how the various iteration methods
%    will vary with time in regard to system wide convergence.
%

%% Build Directory

%% Build Data Vectors
%
%  Check data is all of the same length.

%% Comb Through Detectors
%
%  Check all detectors are of the same size.
%

%% Compare Data
%
%
%  Find the mean and print the standard deviation for the value.
%     Compare this to the reported error.
%     Determine which is most out of bounds.
%
%  Print file containing the data of interest with folder header and
%       include the  absolute and relative differences to the reported
%       value.
%  Print file with external mean and STD.

%% Compare Detectors
%
%  