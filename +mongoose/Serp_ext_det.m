function res = Serp_ext_det(file)
%%
%
%   Compatable with Serpent 2 (maybe Serpent 1??)
%
%   This function extracts detector data from a detector file.  This
%   attempts to be general enough to build information from the near
%   limitless possibilities of detectors.include "detectors"
%
%   res.flag - indicates the type of detector:
%       1    - Single value.
%       2    - f(E)
%       3    - f(r,E)
%
%% Script:

% Read data:
eval(file)

done = 0; % Finished flag
skip = 0; % Skip flag (if >10 then breaks loop)
num = 1;  % Current detector
idx = 0;

while done == 0 % Loop until all detectors are read
    
    % Search for next detector
    det_name = ['DET' num2str(num)];
    
    if exist(det_name,'var') == 0
        skip = skip + 1;
        if skip > 10
            break
        end
        num = num + 1;
    else
        idx = idx + 1;
        
        % Read data:
        R = eval(det_name);
        
        % Clear flags:
        mesh = 0;
        dim = 0;
        eng = 0;
        dx = 0; dy = 0; dz = 0;
        
        N = length(R(:,1));
        
        if N > 1
            
            % Determine detector type:
            if max(R(:,2)) > 1
                eng = 1;
                E = eval([det_name 'E']);
                NE = length(E);
            end
            
            if max(R(:,10)) > 1
                mesh = 1;
                dx = 1;
                dim = dim + 1;
                X{dim} = eval([det_name 'X']);
                NX{dim} = length(X{dim});
            end
            
            if max(R(:,9)) > 1
                mesh = 1;
                dy = 1;
                dim = dim + 1;
                X{dim} = eval([det_name 'Y']);
                NX{dim} = length(X{dim});
            end
            if max(R(:,8)) > 1
                mesh = 1;
                dz = 1;
                dim = dim + 1;
                X{dim} = eval([det_name 'Z']);
                NX{dim} = length(X{dim});
            end
            
            % Fill result output:
            if mesh == 1
                
                % Here, the reshape command is used and the array matrix
                % formulated to match the way reshape organizes the
                % results.
                if eng == 1 && dim == 3
                    res.value{idx,1} = reshape(R(:,11),NX{1},NX{2},NX{3},NE);
                    res.err{idx,1} = reshape(R(:,12),NX{1},NX{2},NX{3},NE);
                    [a b c d] = ndgrid(X{1}(:,3),X{2}(:,3),X{3}(:,3),E(:,3));
                    res.array{idx,1} = a;
                    res.array{idx,2} = b;
                    res.array{idx,3} = c;
                    res.array{idx,4} = d;
                elseif eng == 1 && dim == 2
                    res.value{idx,1} = reshape(R(:,11),NX{1},NX{2},NE);
                    res.err{idx,1} = reshape(R(:,12),NX{1},NX{2},NE);
                    [a b d] = ndgrid(X{1}(:,3),X{2}(:,3),X{3}(:,3),E(:,3));
                    res.array{idx,1} = a;
                    res.array{idx,2} = b;
                    res.array{idx,4} = d;
                elseif eng == 1 && dim == 1
                    res.value{idx,1} = reshape(R(:,11),NX{1},NE);
                    res.err{idx,1} = reshape(R(:,12),NX{1},NE);
                    [a d] = ndgrid(X{1}(:,3),E(:,3));
                    res.array{idx,1} = a;
                    res.array{idx,4} = d;
                elseif eng == 0 && dim == 3
                    res.value{idx,1} = reshape(R(:,11),NX{1},NX{2},NX{3});
                    res.err{idx,1} = reshape(R(:,12),NX{1},NX{2},NX{3});
                    [a b c] = ndgrid(X{1}(:,3),X{2}(:,3),X{3}(:,3));
                    res.array{idx,1} = a;
                    res.array{idx,2} = b;
                    res.array{idx,3} = c;
                elseif eng == 0 && dim == 2
                    res.value{idx,1} = reshape(R(:,11),NX{1},NX{2});
                    res.err{idx,1} = reshape(R(:,12),NX{1},NX{2});
                    [a b] = ndgrid(X{1}(:,3),X{2}(:,3));
                    res.array{idx,1} = a;
                    res.array{idx,2} = b;
                else
                    res.value{idx,1} = reshape(R(:,11),NX{1});
                    res.err{idx,1} = reshape(R(:,12),NX{1});
                    [a] = ndgrid(X{1}(:,3));
                    res.array{idx,1} = a;
                end
                
                res.flag{idx} = 3;
                
            elseif eng == 1
                res.flag{idx} = 2;
                
                res.value{idx,1} = R(:,11);
                res.err{idx,1} = R(:,12);
                res.array{idx,1} = E(:,3);
            end
            
        else
            res.value{idx,1} = R(1,11);
            res.err{idx,1} = R(1,12);
            res.flag{idx,1} = 1;
        end
        num = num + 1;
    end
end