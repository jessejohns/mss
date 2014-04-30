function Serp_plot_all(tar_dir,man,save_dir)
%
%  This scripts runs through the desired directory, plots, and saves the
%  detector outputs into another desired directory.
%
%  This can ony handle certain configurations.
%
%%  Inputs
% Man = 1 will put a user input in making the plots, so that visualization
%         is possible.

% Top directory.
top_dir = pwd;

% Build directory list.
fold = build_dir(tar_dir);

for i = 1:length(fold)
    
    % Find result file
    res_file = Serp_search_res(fold{i});
    
    if str2double(res_file{1}) ~= 0
        
        % Split result into input file
        sp_file = regexp(res_file, '_', 'split');
        in_file = sp_file{1};
        
        % Plot
        Serp_plot_det(fold{i},in_file{1})
        
        close(2)
        if man == 1
            
            fprintf('Currently view %i/%i - %s \n',i,length(fold),fold{i})
            input('\n Hit enter to continue. \n')
            
        end
        close
        if exist('save_dir','var')
        end
        
    end
    
end

cd(top_dir)