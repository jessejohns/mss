function Serp_sense_ana()
%%
%  This just runs a sensitivity study for a manually entered input deck:
%

%% Inputs

set_do = {'Mod_den' 'Pitch' 'Fuel_rad' 'Clad_thick' 'Fuel_temp' 'Mod_temp' 'Fuel_enr' 'Fuel_den' 'Zirc_den'};

set_base = [0.6898 0.6295 0.4025 0.0640 900 600 0.02045 10.4215 6.56];

top_dir = pwd;

% test_name = {'low' 'norm' 'high'};
% test_set = [-0.05 0.0 0.05];
test_name = {'low' 'high'};
test_set = [-0.05 0.05];

burn_file = [top_dir '/burn_steps'];
burn_inv = [top_dir '/burn_inventory'];

for i = 1:length(set_do)
    
    set_name = [set_do{i}];
    
    if exist(set_name,'dir') == 0
        
        mkdir(set_name)
        cd(set_name)
        
        work_dir = pwd;
        
        % Set limits...
        %   So not to reduce temperature where tmp is invalid.
        
        N2 = length(test_name);
        
        if i == 5 || i == 6
            N1 = 2;
        else
            N1 = 1;
        end
        
        for j = N1:N2
            
            % Make and move into sub directory:
            fold_name = [test_name{j}];
            
            if exist(fold_name,'dir') == 0
                
                mkdir(fold_name)
                cd(fold_name)
                
                save_dir = pwd;
                
                copyfile(burn_file,[save_dir '/burn_steps']);
                copyfile(burn_inv,[save_dir '/burn_inventory']);
                
                % Refresh parameters:
                set_new = set_base;
                
                % Make new parameter set:
                set_new(i) = set_new(i) + set_new(i)*test_set(j);
                
                % Make inputs file:
                diary pwr_pin
                
                fprintf('set title "Takahama-3 SF95-3" \n')
                fprintf(' \n')
                fprintf('%% --------- Fuel pin --------- \n')
                fprintf(' \n')
                fprintf('pin 1 \n')
                fprintf('fuel     %f \n',set_new(3))
                fprintf('gas      %f \n',set_new(3)+0.0087)
                fprintf('clad     %f \n',set_new(3)+0.0087+set_new(4))
                fprintf('water \n')
                fprintf(' \n')
                fprintf('surf  1000  sqc  0.0 0.0 %f \n',set_new(2))
                fprintf(' \n')
                fprintf('cell 110  0  fill 1    -1000 \n')
                fprintf('cell 112  0  outside    1000 \n')
                fprintf(' \n')
                fprintf('%% --------- Materials ------------ \n')
                fprintf(' \n')
                fprintf('mat fuel -%f burn 1 tmp %f \n',set_new(8),set_new(5))
                fprintf('92234.09c  0.00020 \n')
                fprintf('92238.09c  %f \n',0.5-set_new(7))
                fprintf('92235.09c  %f \n',set_new(7))
                fprintf('8016.09c  0.99762 \n')
                fprintf('8017.09c  0.00038 \n')
                fprintf(' \n')
                fprintf('mat clad -%f tmp %f       %% Zircaloy 4 \n',set_new(9),set_new(6))
                fprintf('40090.06c  0.5067825  %% Zr = 98.5%% \n')
                fprintf('40091.06c  0.110517 \n')
                fprintf('40092.06c  0.1689275 \n')
                fprintf('40094.06c  0.171193 \n')
                fprintf('40096.06c  0.02758 \n')
                fprintf('50112.06c  0.0001358  %% Sn = 1.40%% \n')
                fprintf('50116.06c  0.0021756 \n')
                fprintf('50117.06c  0.0010752 \n')
                fprintf('50118.06c  0.0033908 \n')
                fprintf('50119.06c  0.0012012 \n')
                fprintf('50120.06c  0.0045626 \n')
                fprintf('50122.06c  0.0006482 \n')
                fprintf('50124.06c  0.008106  \n')
                fprintf('8016.06c  0.00119714 %% O = 0.12%% \n')
                fprintf('26054.06c  0.0001169  %% Fe = 0.20%% \n')
                fprintf('26056.06c  0.00183508 \n')
                fprintf('24052.06c  0.00083989 %% Cr = 0.10%% \n')
                fprintf(' \n')
                fprintf('mat water  -%f tmp %f  moder lwtr 1001 \n',set_new(1),set_new(6))
                fprintf('1001.06c  2 \n')
                fprintf(' 8016.06c  1 \n')
                fprintf(' \n')
                fprintf('mat gas  -1e-2 \n')
                fprintf('2004.06c 1 \n')
                fprintf(' \n')
                fprintf('mat U235 1 \n')
                fprintf('92235.09c  1 \n')
                fprintf(' \n')
                fprintf('mat U238 1 \n')
                fprintf('92238.09c  1 \n')
                fprintf(' \n')
                fprintf('therm lwtr lwe7.06t \n')
                fprintf(' \n')
                fprintf('%% --------- Other stuff --------- \n')
                fprintf(' \n')
                fprintf('set seed 1314570939 \n')
                fprintf(' \n')
                fprintf('include "/home/jesse/Simulations/Serpent/ENDF_lib" \n')
                fprintf(' \n')
                fprintf('set bc 2 \n')
                fprintf(' \n')
                fprintf('set pop 6000 300 10 1.0 \n')
                fprintf('set dt -.9 \n')
%                 fprintf('set egrid 5e-5\n')
                fprintf(' \n')
                fprintf('%% --------- Detectors --------- \n')
                fprintf(' \n')
                fprintf('ene 1 3 200 1E-10 20 \n')
                fprintf('%% ene 2 1 1e-11 1e-6 1e-3 20 \n')
                fprintf(' \n')
                fprintf('det 1 de 1 \n')
                fprintf('det 2 de 1 dt -3 dr -1 U235 \n')
                fprintf('det 3 de 1 dt -3 dr -1 U238 \n')
                fprintf(' \n')
                fprintf('%% --------- Burn up --------- \n')
                fprintf(' \n')
                fprintf('include "burn_steps" \n')
                fprintf('include "burn_inventory" \n')
                fprintf(' \n')
                fprintf('set bumode 2 \n')
                fprintf('set pcc 1 \n')
                fprintf('set xscalc 2 \n')
                fprintf('set printm 0 \n')
                
                diary off
                
                % Run file
                !sss pwr_pin
                
                cd(work_dir)
                
                % Print data;
                
                Serp_burn_data(test_name(j), 1, [1 2], 1, save_dir)
                
            end
            
        end
        cd(top_dir)
        
    end
    
end

