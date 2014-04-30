function [tally,tally_type] = MCNP_extract(fileID,burn_option)
%% MCNP_extract('mcnp_output_name')
%
%  This script will search the user inputed file and extract tally
%  information.  They will then be set into an array that can then be
%  plotted.  It is up to the user, however, to recognize the format of the
%  tallies.  This script will make an attempt at the more common tallies.
%
%  This script will also search for burnup history if burn option = 1.
%
% Written by: Jesse Johns, 2011
%             Texas A&M University
%
% This currently can only support one tally type at a time.
% clear;clc
% fileID = 'source_totnu_01_out';
% burn_option = 0;
%
%% To add:
%  Data sheets
%     make code go one tally at a time and print data to .xls
%  Tally 5 compatability.

if exist('burn_option','var')
    ...
else
    burn_option = 0;
end

%% Open/Read/Rewrite input file:

id = fopen(fileID);

if (id < 0)
    error('Could not open output file.');
end

in_line = fgetl(id);

while ischar(in_line) > 0;
    
    %% Find Tally stuff:
    
    cur_line = strfind(in_line,'1tally');
    
    if cur_line > 0;
        
        if  strfind(in_line,'fluctuation')
            ...
        else
        
        if (exist('idx', 'var'));
            idx = idx + 1;
        else
            idx = 1;
        end
        
        % Looks for tally comment
        next_line = fgetl(id);
        
        if strfind(next_line,'+') > 0
            if strfind(next_line,'single_tally') > 0
                next_split = regexp(next_line,' ','split');
                tally_type{idx,2} = next_line;
            else
                tally_type{idx,2} = next_line;
            end
        else
            tally_type{idx,2} = 'Not commented';
        end
        
        % Determine tally type:
        count = 0;
        
        while count < 3; % This loop finds the start of the data.
            
            count = count + 1;
            
            if strfind(next_line,'tally type') > 0
                next_split = regexp(next_line,' ','split');
                tally_type{idx,1} = next_split(14);
                break
            end
            
            next_line = fgetl(id);
        end
        
        %% For F4 Tally:
        
        if strcmp(tally_type{idx,1},'4') > 0
            
            cont = -1;
            count = 0;
            
            if strfind(tally_type{idx,2},'single_tally') > 0
                
                %% Single data
                count = 0;
                
                while count < 100;
                    count = count + 1;
                    
                    next_line = fgetl(id);
                    if strfind(next_line,'cell') > 0
                        
                        while count < 100
                            count = count + 1;
                            next_line = fgetl(id)
                            next_split = regexp(next_line,' ','split');
                            
                            if length(next_split) == 19;
                                tally(1,idx) = str2double(next_split(18));
                                tally(2,idx) = str2double(next_split(19));
                                count = 1e3;
                                break
                            end
                        end
                        
                    elseif count > 100
                        break
                    end
                end
            else
                %% Energy spectrum
                lost = 0;
                loop = 0;
                
                while loop == 0
                    junk = fgetl(id);
                    lost = strfind(junk,'energy');
                    if lost > 0
                        break
                    end
                end
                
                if lost > 0
                    next_line = fgetl(id);
                    
                    count = 0;
                    while count < 1e5; % This loop extracts the data from the tally.
                        count = count+1;
                        next_split = regexp(next_line,' ','split');
                        
                        end_line = strfind(next_line,'total');
                        
                        if end_line > 0;
                            break
                        else
                            tally(count,1,idx) = str2double(next_split(5));
                            tally(count,2,idx) = str2double(next_split(8));
                            tally(count,3,idx) = str2double(next_split(9));
                        end
                        
                        next_line = fgetl(id);
                    end
                    
                end
            end
        else
            ...
        end % End TALLY 4 Loop
        end
        
        clear cur_line
    else
        ...
    end % End Tally section

%% Find Burnup stuff:

if burn_option == 1;
    
    cur_line = strfind(in_line,'1burnup summary table by material');
    idx = 0;
    
    if cur_line > 0;
        
        if (exist('idx', 'var'));
            idx = idx + 1;
        else
            idx = 1;
        end
        
        % Collect history data:
        
        next_split = regexp(in_line,' ','split');
        
        
        for i = 1:7
            junk = fgetl(id);
        end
        
        cont = -1;
        count = 0;
        
        while cont < 0; % This loop extracts the data from the tally.
            count = count + 1;
            
            next_line = fgetl(id);
            
            next_split = regexp(next_line,' ','split');
            
            if length(next_split) < 2;
                cont = 1;
                break
            else
                step(count) = str2double(next_split(5));
                duration(count) = str2double(next_split(8));
                time(count) = str2double(next_split(9));
                power(count) = str2double(next_split(10));
                keff(count) = str2double(next_split(11));
                flux(count) = str2double(next_split(12));
                nu(count) = str2double(next_split(13));
                q(count) = str2double(next_split(14));
                burnup(count) = str2double(next_split(15));
                source(count) = str2double(next_split(16));
            end
        end
    end % End Burnup loop
    
    clear cur_line
    
else
    ...
end

in_line = fgetl(id);
end

fclose all;

% end
