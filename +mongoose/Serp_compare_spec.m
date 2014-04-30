%function Serp_compare_spec(fold,file,op)
%% Serp_compare_spec(fold,file,op)
%
%  This compares Serpent (op = 1) with itself or with MCNPX (op = 2),
%  where op = [1 2] is a comparison of Serpent to MCNP, for example.
%
%  Point to directory and include file name in vector in {}.
%    The directoy can be absolute or from current directory.
%
%% TODO
%  Generalize this into a function.

%% Notes
%
%  There are various loops in the Serpent data since often there are
%  various names given to the detectors.
%
%  This only supports three comparisons, currently.
%
%  For scaling, try to conventionally put MCNPX first.
%
%  Legends are manually inputted below.

close all; clear

%% Inputs:
man = 1;
main_dir = '.';
file_d = 'pwr';
save_name = {[main_dir '_spec'],[main_dir '_log_spec'],[main_dir '_error']};
s = 0;
p_error = 0;

if man == 1
    % -----------------------------------------------------------------------
    %     fold = {'MCNPX' 'MCNPX'  'Thermal_EOL' 'Thermal_EOL_ures' 'Thermal_EOL_ures_2'};
    %     % file = {'detailed_spectrum' 'thermal_pin' 'thermal_pin'};
    %     file = {'MCNPX_spec_EOL' 'MCNP_spec_EOL' file_d file_d file_d};
    %     leg_1 = {'MCNPX' 'MCNP5' 'Serpent' 'Serpent Ures' 'Serpent Ures 2'};
    %
    %     % 2 - mcnpx, 1 - serpent
    %     op = [2 2 1 1 1];
    %
    %     % Error bars:
    %     op_error = [0 0 0 0 0];
    %
    %     % How to do comparison? Select "main"
    %     op_main = 1;
    %
    %     % Plotter options
    %
    %     plot_set = [1 2 3];
    
    % -----------------------------------------------------------------------
    fold = {'PWR' 'PWR_SiC'};
    % file = {'detailed_spectrum' 'thermal_pin' 'thermal_pin'};
    file = {file_d file_d };
    leg_1 = {'PWR' 'PWR SiC'};
    
    % 2 - mcnpx, 1 - serpent
    op = [1 1];
    
    % Error bars:
    op_error = [0 0];
    
    % How to do comparison? Select "main"
    op_main = 1;
    
    % Plotter options
    
    plot_set = [1 2 3];
    % ------------------------------------------------------------------------
    
elseif man == 0
    
    fold = build_dir(main_dir);
    
    cd(main_dir)
    for i = 1:length(fold)
        
        Serp_search_res(fold{i})
        
        file{i} = file_d;
    end
    
    leg_1 = fold;
    op = ones(1,N);
    op_error = op*p_error;
    op_main = 1;
    plot_set = [1 2 3];
    
end
%% Start
top_dir = pwd;

cd(main_dir)

work_dir = pwd;

for i = 1:length(op)
    
    clear DET*
    
    cd(fold{i});
    
    if op(i) == 1
        num = 0;
        done = 0;
        
        % Find detector file:
        while done == 0;
            if exist([file{i} '_det' num2str(num)],'file')
                evalstring = [file{i} '_det' num2str(num)];
                eval(evalstring)
                break
            else
                num = num + 1;
                if num > 100
                    error('Could not find Serpent detector.')
                end
            end
        end
        
        % Find detector variable:
        num = 0;
        
        while done == 0;
            if exist(['DET' num2str(num)],'var')
                clear S_DET S_DETE
                s_1 = ['S_DET = DET' num2str(num) ';'];
                s_2 = ['S_DETE = DET' num2str(num) 'E;'];
                eval(s_1); eval(s_2);
                break
            else
                num = num + 1;
                if num > 100
                    error('Could not find Serpent detector.')
                end
            end
        end
        
        %         if i > 1
        %             if size(det_e,2) ~= size(S_DETE,2)
        %                 error('Detector size mismatch.')
        %                 % Detectors are required to be the same size in order to
        %                 % properly determine the error.
        %             end
        %         end
        det_e(:,i) = (S_DETE(:,2)+S_DETE(:,1))/2;
        det_val(:,i) = S_DET(:,11);
        det_err(:,i) = S_DET(:,11).*S_DET(:,12);
        det_aerr(:,i) = S_DET(:,12);
        
    elseif op(i) == 2
        
        % Extract MCNP data
        M_DET_a = MCNP_extract(file{i});
        
        det_ep(:,i) = M_DET_a(:,1);
        det_val(:,i) = M_DET_a(2:end,2)/0.9756;
        det_err(:,i) = M_DET_a(2:end,2).*M_DET_a(2:end,3);
        det_rerr(:,i) = M_DET_a(2:end,3);
        
        % Redefine MCNP energy bins:
        for k = 1:length(det_ep)-1
            det_e(k,i) = (det_ep(k,i)+det_ep(k+1,i))/2;
        end
        
    else
        ...
    end

cd(work_dir)
end

%% Plotting
%   this is fairly simple right now.
if exist('S_det_val','var')
    s_size = size(S_det_val);
    Ns = s_size(2);
end

if exist('M_det_val','var')
    m_size = size(M_det_val);
    Nm = m_size(2);
end

k = 0;
m = 0;
line_spec = {'r' 'b' 'k' 'm' '--b' '--r'};
err_spec = {'.r' '.b' '.k' '.m' '.b' '.r'};


%% Plot data:
for i = 1:length(op_error)
    for h = 1:length(plot_set)
        
        clear h_set
        
        if h == 1
            figure(h)
            semilogx(det_e(:,i),det_val(:,i),line_spec{i});
            
            if op_error(i) == 1
                h_set = errorbar(det_e(:,i),det_val(:,i),det_err(:,i),line_spec{i});
                
                hAnnotation = get(h_set,'Annotation');
                hLegendEntry = get(hAnnotation','LegendInformation');
                set(hLegendEntry,'IconDisplayStyle','off')
            end
            
            hold on
            grid on
            whitebg('white')
            set(gcf,'Color',[1 1 1])
            xlabel('Energy [MeV]')
            ylabel('Flux [n/cm/s^2]')
            
            set(gca,'xscale','log');
            set(gca,'yscale','lin');
            
        elseif h == 2
            
            figure(h)
            semilogx(det_e(:,i),det_val(:,i),line_spec{i});
            
            if op_error(i) == 1
                h_set = errorbar(det_e(:,i),det_val(:,i),det_err(:,i),line_spec{i});
                
                hAnnotation = get(h_set,'Annotation');
                hLegendEntry = get(hAnnotation','LegendInformation');
                set(hLegendEntry,'IconDisplayStyle','off')
            end
            
            hold on
            grid on
            whitebg('white')
            set(gcf,'Color',[1 1 1])
            xlabel('Energy [MeV]')
            ylabel('Flux [n/cm/s^2]')
            
            set(gca,'xscale','log');
            set(gca,'yscale','log');
            
        elseif h == 3
            if i ~= op_main
                figure(h)
                diff_val(:,i) = (det_val(:,op_main) - det_val(:,i))./det_val(:,op_main);
                semilogx(det_e(:,i),diff_val(:,i),line_spec{i});
                hold on;
                %                 h_set = semilogx(det_e(:,i),det_aerr(:,i),err_spec{i});
                %                 h_set_2 = semilogx(det_e(:,i),-det_aerr(:,i),err_spec{i});
                
                grid on
                whitebg('white')
                set(gcf,'Color',[1 1 1])
                xlabel('Energy [MeV]')
                ylabel('Relative Error')
                
                set(gca,'xscale','log');
                set(gca,'yscale','lin');
                
            end
        end
        
        legend(leg_1,'Location','Best')
        
    end
end

%% Save:
% figure(3)
% for i = 2:length(leg_1)
%     leg{i-1} = leg_1{i};
% end
% axis([1e-10 10 -.05 .05 ])
% figure(1)
% axis([1e-10 10 0 18e11])
% figure(2)
% axis([1e-10 10 1e4 1e14])
% figure(3)
% legend(leg,'Location','Best')
%
% cd ..


%% Scaling for Serpent:
scale = 1;
if scale == 1
    for i = 1:length(op_error)
        frac(i) = mean(det_val(100:end,1)./det_val(100:end,i));
    end
end

if s > 0
    
    saveas(1,[main_dir '_spec'],'png')
    saveas(2,[main_dir '_log_spec'],'png')
    saveas(3,[main_dir '_err'],'png')
    
    % Set figures to be pdfable...
    for i = 1:3
        set(i, 'PaperPosition', [0 0 5 3.5]);
        set(i, 'PaperSize', [5 3.5]);
    end
    
    saveas(1,[main_dir '_spec'],'pdf')
    saveas(2,[main_dir '_log_spec'],'pdf')
    saveas(3,[main_dir '_err'],'pdf')
end

cd(top_dir)