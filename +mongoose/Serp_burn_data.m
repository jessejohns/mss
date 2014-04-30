function Serp_burn_data(prefix, man, data, s, save_dir)
%
%  This function compares the final isotopics with benchmark data.
%

%% Inputs:

% man
%    1  = just folder data
%  else = use uncertainty mean

% data
%   [a b]
%    a = data set
%    b = subdata set

var_use = 'TOT_MASS';
top_dir = pwd;

%% Testing inputs:
% prefix = {'Fine'};
% man = 1;
% data = [1 2];
% s = 1;
% save_dir = '.';

%% Description
%
%  The BURNUP data point that is closest to the total burnup of the
%  experimental data will be used.

%% Checks

if exist('s','var') == 0
    s = 0;
end

if exist('save_dir','var') == 0
    save_dir = pwd;
end

if exist('data','var') == 0
    error('Data input required for this script')
end

%% Get directories:

if man == 2;
    fold = build_dir(prefix);
    cd(prefix)
elseif man == 3;
    fold = build_dir(prefix, 1);
    cd(prefix)
elseif man == 1;
    fold = {prefix};
    fold = fold{1};
end

%% Loop for mats
m_end = 1;
mat = 1;
count = 0;

work_dir = pwd;

while m_end > 0
    
    %% Read data
    
    for i = 1:length(fold);
        
        clear idx
        
        clear(var_use)
        
        % Find depletion file:
        dep_file = Serp_search_dep(fold{i});
        
        % Swap to directory:
        cd(fold{i})
        eval(dep_file{1});
        cd(work_dir)
        
        if i == 1
            name = NAMES(mat,:);
            burn = BU;
            zaid = ZAI;
        end
        
        if length(burn) == length(BU)
            
            mat_2 = 0;
            done = 0;
            
            while done == 0
                
                mat_2 = mat_2 + 1;
                
                if mat_2 <= length(ZAI)
                    
                    if ZAI(mat_2) == zaid(mat)
                        
                        dat_string = ['dat_burn(i,:) = ' var_use '(mat_2,:);'];
                        eval(dat_string)
                        
                        break
                        
                    end
                    
                else
                    break
                end
            end
            
        else
            error('The burn steps are not equal. \n  This script requires that they are.')
        end
        
    end
    
    %% Uncertainties:
    
    dat_mean(mat) = mean(dat_burn(:,end));
    dat_std(mat) = std(dat_burn(:,end));
    
    % Last burnup:
    last_burn = burn(end);
    
    %% Benchmark Data:
    
    [NUC BU_ben ATM SET_NAME] = Serp_bench_data(data(1),data(2));
    
    % Find nuclide:
    clear mat_find
    
    for j = 1:size(NUC,1)
        if strfind(name,NUC{j,1})
            
            count = count + 1;
            
            if strcmp(var_use,'TOT_MASS')
                ATM = ATM*4.67;
            else
                ATM = ATM/43.2;
            end
            
            ATM_std = ATM(j,:).*NUC{j,2};
            
            %% Search data:
            %
            err_tol = 0.5;
            K = 0;
            
            for m = 1:length(BU_ben)
                
                dBU = abs(BU_ben(m)-last_burn);
                
                if dBU < err_tol
                    K = m;
                end
                
            end
            
            if K == 0
                error('Could not find burnup match.  Try raising tolerance: %3.2f',err_tol)
            end
            
            % C/E
            
            differ = dat_mean(mat)/ATM(j,K);
            
            G(count,1) = zaid(mat);
            G(count,2) = dat_mean(mat);
            G(count,3) = dat_std(mat);
            G(count,4) = ATM(j,K);
            G(count,5) = ATM_std(K);
            G(count,6) = differ;
            
            
        end
    end
    
    if ZAI(mat) == 666
        m_end = 0;
    else
        mat = mat + 1;
    end
    
end

%% Save data:

if s > 0
    delete([prefix{1} '_ben_compare.csv'])
    
    cd(save_dir)
    dlmwrite([prefix{1} '_ben_compare.csv'],G)
else
    G
end

cd(top_dir)
