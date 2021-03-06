function readCellFOAM(ID,opt)
%% readCellFOAM(ID,opt)
%
%   This function reads the cells txt file of an OpenFOAM mesh and
%   generates a corresponds material file for reading into Serpent 2
%   multiphysics interface.
%
% Inputs:
%   ID: file name
%
%   opt.mat = {'name of material for cell 1' 'cell2' ...} in order of the
%               cellZones file.
%      .work = 'string if working directory is different than ID location'
%
%% Test inputs:
% ID = 'cellZones';
% opt.mat = {'fuel' 'mod'};
% opt.rho = [10.421 0.989];

%% Check inputs:
if isfield(opt,'mat') == 0
    error('opt.mat input required.')
end

%% Checkout directory:
cur_dir = pwd;

if isfield(opt,'work') == 1
    cd(opt.work)
end

%% Load file:

od = fopen(ID);

if (od < 0)
    error('Could not open input file.');
end

%% Start search

in_line = fgetl(od);

flag_junk = 0;
flag_cell = 0;

k = 0;

while ischar(in_line);
    
    % Clear through header.
    if flag_junk == 0
        flag_junk = 1;
        for i = 1:16
            in_line = fgetl(od);
        end
    end
    
    in_line = fgetl(od);
    
    if ischar(in_line)
        
        % Set number of regions and check:
        if flag_cell == 0
            
            num_test = str2double(in_line);
            
            if num_test > 0
                num_cell = num_test;
                flag_cell = 1;
                if num_cell ~= length(opt.mat)
                    error('The number of regions does not equal the opt.mat input.')
                end

            end
        else
            
            if strfind(in_line,'cellLabels')
                
                k = k + 1;
                in_line = fgetl(od);
                arrayLength = str2double(in_line);
                
                G{k}.arrayLength = arrayLength;
                G{k}.index = zeros(arrayLength,1);
                
                in_line = fgetl(od);
                
                % OpenFOAM indicies start with zero, since MATLAB uses 1
                % for the first index, we need to increase it by 1.
                
                for i = 1:arrayLength
                    in_line = fgetl(od);
                    G{k}.index(i) = str2double(in_line)+1;
                end
                
            end
            
            if k == num_cell
                break;
            end
        end
    end

end

fclose(od);

%% Write material:
%
%  G{i} is the set of indicies for region i.

tot_cell = 0;

for i = 1:num_cell
    
    tot_cell = tot_cell + G{i}.arrayLength;
    
end

for i = 1:num_cell
   
    for j = 1:G{i}.arrayLength
       
        bigMAT{G{i}.index(j)} = opt.mat{i};
        bigIDX{G{i}.index(j)} = j;
        bigRHO{G{i}.index(j)} = opt.rho(i);
        bigTMP{G{i}.index(j)} = 300;
        
    end
end

%% Write file:
delete materials

diary materials
fprintf('%i\n',tot_cell);

for i = 1:length(bigMAT);
    fprintf('%s\n',bigMAT{i});
end
diary off

%% Write mapping
delete map

diary map
fprintf('%i\n',tot_cell);

for i = 1:length(bigIDX)
    fprintf('%i\n',bigIDX{i});
end
diary off

%% Write temperature and density:
cd ../../0

delete T
delete rho

diary T
fprintf('%i\n',tot_cell);

for i = 1:length(bigTMP);
    fprintf('%i\n',bigTMP{i});
end
diary off

diary rho
fprintf('%i\n',tot_cell);

for i = 1:length(bigRHO);
    fprintf('%i\n',bigRHO{i});
end
diary off

cd(cur_dir)
