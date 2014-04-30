function Serp_plot_mat(prefix, man,opt)
%% Serp_plot_mat(prefix, man,opt)
%
% Written by:
%    Jesse Johns
%    Texas A&M University
%
% Description:
%
%   This function plots the isotopical changes as a function of burnup.
%   There are other option that are available for changing within the
%   script.  Currently, overrides are not available due to desire for
%   simplicity in calling the script.
%
% - Input variables: - - - - - - - - - - - - - - - - - - - - - - - - - -
%
%   prefix - carries different meanings.
%
%   man = 0 for automatic directory determination base on prefix.
%
%   s  = 1 to save images in .png format
%      = 2 to save images in .pdf
%      = 0 to be prompted to wait/save
%     ~= 0 there will not be any waiting for user input.
%
%   save_dir, directory to save data.
%
%   data = [a b c d]
%      a, 1 = plot
%      b, data set from Serp_bench_data.m
%      c. secondary data set
%      d, >0 will save vector for the last in a file named after the
%         directory listing
%
%   lege, allows for manually overriding the legend displayer.
%         - defaults to using the directory list.
%
%   opt.pin must be a string.  This allows that the
%
%   opt.log = 1 to plot y in log scale.
%
%   opt.idx = [] to plot only certain nuclides, this corresponds to the
%             index of the nuclide.  You get this by running through the
%             plot at least once.
%
%   opt.keep = 1 to keep plots on scree, defaults to 0, otherwise can get 
%              hairy.

%% Example
%  Serp_plot_mat('TEMP',2,[1 1 3])
%
% prefix = 'Temporal';
% man = 2;
% opt = 1;

%% TODO
%  Error plotting
%    - What did I want here? There are no reported errors for materials -
%    error between the runs an the mean?
%  Lattice plotting
%    - This is for treating pins individually so that calls don't have to
%    be made within the script. - Add an option??
%  Add an option to plot in a subplot select isotopes.

import mongoose.*

%% Checks

if isfield(opt,'save_dir') == 0
    opt.save_dir = pwd;
end

if isfield(opt,'s') == 0
    opt.s = 0;
end

if isfield(opt,'data') == 0
    opt.data = 0;
end

if isfield(opt,'var_use') == 0
    opt.var_use = 'TOT_ADENS';
end

if isfield(opt,'time_use') == 0
    opt.time_use = 'BU';
end

if isfield(opt,'sss2') == 0
    opt.sss2 = 1;
end

if isfield(opt,'plot') == 0
    opt.plot = 1;
end

if isfield(opt,'log') == 0
    opt.log = 0;
end

if isfield(opt,'idx') == 0
    opt.idx = [1:1:1000];
else
    if opt.idx == 0
        opt.idx = [1:1:1000];
    end
end

if isfield(opt,'kep') == 0
    opt.keep = 0;
end
%% Start script:

% Initialize:
mat = 0;
m_end = 1;

% Some other variable declerations:
if strcmp(opt.time_use,'BU')
    xaxis_label = 'Burnup [MWd/kg]';
else
    xaxis_label = 'Time [days]';
end

if strcmp(opt.var_use,'TOT_MASS')
    yaxis_label = 'Mass';
else
    yaxis_label = 'Atomic Density';
end

%% Loop for mats

work_dir = pwd;

% Grab data:
output = Serp_ext_mat(prefix,man,opt);

% Organize based on nuclide data:


%% List of lines styles:
N = length(output.fold);
line_style = {'b-','r-','k--','b--','g--','m--','r-.','b-.','k-.','m-.'};

if N > length(line_style)
    error('Number of folders too great, add more line specifications.')
end

while m_end > 0
    
    mat = mat+1;
    
    %% Plotting
    flag_plot = 0;
    for i = 1:length(opt.idx)
        
        if opt.idx(i) == mat
            flag_plot = 1;
            break;
        end
        
    end
    
    if opt.plot == 1 && flag_plot == 1
        
        if opt.keep == 0;
            figure(1); clf;
        else
            figure;
            fprintf('Keep option not working, for some reason \n');
        end
        
        if opt.log == 1
            
            for i = 1:N;
                
                semilogy(output.burn{i}, output.data{mat,i},line_style{i},'LineWidth',2); %#ok<*USENS>
                hold on;
            end
            
        else
            
            for i = 1:N;
                
                plot(output.burn{i}, output.data{mat,i},line_style{i},'LineWidth',2); %#ok<*USENS>
                hold on;
            end
            
        end
        
        xlabel(xaxis_label)
        ylabel(yaxis_label)
        
        title(output.name(mat,:))
        prettyPlot(gcf)
        
        % Build legend:
        
        lege = output.fold;
        
        %% Include Benchmark data
        %
        %  These data at often in g/g of U
        %     The uncertainty seems to be incorrectly calculated as well...
        
        if opt.data(1) == 1;
            
            data_spec = {'ks' 'rs' 'gs'};
            
            for k = opt.data(3)
                
                if sss2 == 1
                    [NUC BU ATM SET_NAME] = Serp_bench_data2(data(2),k);
                else
                    [NUC BU ATM SET_NAME] = Serp_bench_data(data(2),k);
                end
                
                lege{length(lege)+1} = SET_NAME;
                
                if strcmp(var_use,'TOT_MASS')
                    ATM = ATM*4.67;
                else
                    ATM = ATM/43.2;
                end
                
                % Find data:
                for j = 1:size(NUC,1)
                    if strfind(ouput.name(mat,:),NUC{j,1})
                        
                        data_unc = ATM(j,:).*NUC{j,2};
                        
                        plot(BU,ATM(j,:),data_spec{k})
                        h_bar = errorbar(BU,ATM(j,:),data_unc,data_unc,data_spec{k});
                        
                        hAnnotation = get(h_bar,'Annotation');
                        hLegendEntry = get(hAnnotation','LegendInformation');
                        set(hLegendEntry,'IconDisplayStyle','off')
                        
                    end
                end
            end
            
            cd(work_dir)
            
        end
        
        %% Complete Plotting
        
        if exist('lege','var')
            legend(lege,'Location','EastOutside','Interpreter', 'none')
        else
            legend(fold,'Location','EastOutside','Interpreter', 'none')
        end
        
        %% Loop input/output
        fprintf('Showing figure %i/%i \n',mat,length(output.name(:,1)))
        
        if opt.s == 0
            save_it = input('Save? \n   Type: 1 - yes as png \n         2 - yes as eps ');
            
            if save_it > 0
                saveplot(opt.save_dir,int2str(zaid(mat)),save_it)
            end
            
            clear save_it
            
        elseif opt.s > 0
            saveplot(opt.save_dir,int2str(zaid(mat)),opt.s)
        end
        
    end
    % Set break point:
    if strcmp(output.name(mat,:),'total           ') == 1
        break
    end

    clc
    
end

cd(work_dir)
