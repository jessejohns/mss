function [keff dk] = MCNP_find_k(fileID)
%% MCNP_find_k(fileID,use_code)
%

%% Load ouput file:

od = fopen(fileID);

if (od < 0)
    error('Could not open output file.');
end

%% Start search

r_line = fgetl(od);

while ischar(r_line);
    
    clear keff_line
    
    keff_line = strfind(r_line,'collision/absorption/track-length');
    
    if keff_line > 0;
        split_line = regexp(r_line,' ','split');
        keff = str2double(split_line(10));
        dk = str2double(split_line(17));
        break
    end
    
    r_line = fgetl(od);
end

fclose(od);

end