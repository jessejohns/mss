function G = Serp_phd_readout(fileID)
%  This function reads the console output of a Serpent run and sets up a
%  structure for all of the data printed at each predictor run.
%
%  This is specific to my PhD only.
%
%% Directory:
%
cur_dir = pwd;

%% Load file:
%
id = fopen(fileID);

if (id < 0)
    error('Could not open output file.');
end

%% Scan file:
in_line = fgetl(id);

% Reset index:
step = 1;
iter = 1;
flag_1 = 0;

while ischar(in_line);
    
    if strfind(in_line,'fissrate_o') > 0;
        
        % Search for data:
        flag_1 = 1;
        flag = 0;
        val = 0;
        
        while flag == 0;
            
            if ischar(in_line)
                split_line = regexp(in_line,' ','split');
                
                
                for i = 1:length(split_line)
                    num_test = str2double(split_line(i));
                    
                    if num_test > 0 || num_test < 0
                        val = val + 1;
                        G(step,iter,val) = num_test;
                        break;
                    end
                end
            else
                ...
            end
        
        in_line = fgetl(id);
        
        if strfind(in_line,'burnup') > 0
            flag = 1;
        end
        
        end
        
        % Reset and advance index:
        iter = iter + 1;
        
    end
    
    if (strfind(in_line,'Sampling') > 0)
        if (flag_1 == 1)
            step = step + 1;
            iter = 1;
            flag_1 = 0;
        end
    end
    
    in_line = fgetl(id);
end

fclose(id);

diary off