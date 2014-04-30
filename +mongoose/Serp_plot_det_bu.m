function Serp_plot_det_bu(fold,fileID,wait,rang,op_er)
%
fprintf('This function is only compatible with Serpent 1 \n.')
% fold = '.';
% fileID = 'Reactor_model';
% rang = [ 1e-3 10];

top_dir = pwd;

%% Options:
% op_er, 1 = error bars
if exist('op_er','var') == 0
    op_er = 0;
end

if exist('wait','var') == 0
    wait = 0;
end

%%  - Load data:
d_end = 1;
num = 0;

while d_end > 0;
    
    cd(fold)
    
    if exist([fileID '_det' num2str(num)],'file') > 0;
        evalstring = [fileID '_det' num2str(num)];
        eval(evalstring)
    else
        break
    end
    
    cd(top_dir)
    
    num = num+1;
    
    det_read = 1;
    det_num = 0;
    k = 0;
    
    while det_read > 0
        
        k = k + 1;
        
        % Set variables:
        
        ext_string = ['cont = exist(''DET' num2str(det_num) ...
            ''',''var'');'];
        
        eval(ext_string)
        
        if cont > 0;
            clear val err X Y Z x y z det_val is_eng is_z is_y is+x vol spectrum
            
            vol_string = ['vol = DET' num2str(det_num) '_VOL;'];
            is_x_string = ['is_x = DET' num2str(det_num) '_XBINS;'];
            is_y_string = ['is_y = DET' num2str(det_num) '_YBINS;'];
            is_z_string = ['is_z = DET' num2str(det_num) '_ZBINS;'];
            is_eng_string = ['is_eng = DET' num2str(det_num) 'E;'];
            det_string = ['det_val = DET' num2str(det_num) ';'];
            
            eval(vol_string);
            eval(is_x_string);
            eval(is_y_string);
            eval(is_z_string);
            eval(is_eng_string);
            eval(det_string);
            
            if vol == 1;
                name = ['''DET' num2str(det_num) '-total'];
            end
            
            if is_x > 1;
                x_string = ['x = DET' num2str(det_num) 'X;'];
                eval(x_string);
                X = (x(:,1)+x(:,2))/2;
            end
            
            if is_y > 1;
                y_string = ['y = DET' num2str(det_num) 'Y;'];
                eval(y_string);
                Y = (y(:,1)+y(:,2))/2;
            end
            
            if is_z > 1;
                z_string = ['z = DET' num2str(det_num) 'Z;'];
                eval(z_string);
                Z = (z(:,1)+z(:,2))/2;
             elseif is_y > 1;
                Z = [1];
            end
            
            if is_eng > 1;
                eng_string = ['eng = DET' num2str(det_num) 'E;'];
                eval(eng_string);
                det_eng = (eng(:,1)+eng(:,2))/2;
            end
            
            %% Data to plot:
            
            % Build matrix:
            for k = 1:size(det_val,1)
                
                val(det_val(k,9),det_val(k,10),det_val(k,8),det_val(k,2)) ...
                    = det_val(k,11);
                err(det_val(k,9),det_val(k,10),det_val(k,8),det_val(k,2)) ...
                    = det_val(k,12);
                val_err = val.*err;
            end
            
            if size(val,1) == 1 && size(val,2) == 1 && size(val,3) == 1
                for i = 1:size(val,4)
                    spectrum(i) = val(1,1,1,i);
                    plot_type = 2;
                end
            end
            
            %% Plot
            
            if exist('spectrum','var') == 1;
                
                figure(1)
                loglog(det_eng,spectrum); hold on;
                if op_er == 1
                    errorbar(det_eng,spectrum,val_err,'xk')
                end
                xlabel('Energy (MeV)')
                ylabel('Flux')
                whitebg('white')
                set(gcf,'Color',[1 1 1]);  grid on
                set(gcf,'Position',[577   533   599   477])
                
                figure
                semilogx(det_eng,spectrum); hold on;
                if op_er == 1
                    errorbar(det_eng,spectrum,val_err,'xk')
                end
                xlabel('Energy (MeV)')
                ylabel('Flux')
                whitebg('white')
                set(gcf,'Color',[1 1 1]);  grid on
                set(gcf,'Position',[577   533   599   477])
                
                save('Spec.mat')
                
            elseif exist('val','var') == 1
                
                val_size = size(val);
                
                if length(val_size) == 4 && val_size(3) > 1;
                    for i = 1:size(rang,1)
                        new_val = sum_eng(val,det_eng,rang(1),rang(2));
                        new_err = err;
                        
                        % Rebuild matrices to square (X,Y)
                        
                        %   This one is if the plot is (x,z) so we replace
                        %   y with z, essentially.
                        if length(X) ~= length(Y)
                            if length(Z) > length(Y)
                               
                                new_val_1 = zeros(length(Z),length(X),length(Y));
                                new_err_1 = zeros(length(Z),length(X),length(Y));
                                val_1 = zeros(length(Z),length(X),length(Y));
                                err_1 = zeros(length(Z),length(X),length(Y));
                                        
                                for k = 1:length(Z)
                                    for j = 1:length(Y)
                                        for m = 1:length(X)
                                        
                                        new_val_1(k,m,j) = new_val(j,m,k);
                                        new_err_1(k,m,j) = new_err(j,m,k);
                                        val_1(k,m,j) = val(j,m,k);
                                        err_1(k,m,j) = err(j,m,k);

                                        end
                                    end
                                end
                                X_1 = X;
                                Y_1 = Z;
                                Z_1 = Y;
                            end
                        else
                            new_val_1 = new_val;
                            new_err_1 = new_err;
                            Y_1 = Y;
                            Z_1 = Z;
                            X_1 = X;
                        end
                        
                        if exist('new_val','var') == 1;
                            slice_max(X_1,Y_1,Z_1,new_val_1,new_err_1)
                        end
                    end
                elseif val_size(3) > 1

                    val_1 = val;
                    err_1 = err;
                    Y_1 = Y;
                    Z_1 = Z;
                    X_1 = X;
                    
                    slice_max(X_1,Y_1,Z_1,val_1,err_1)
                else
                    
                    new_val = sum_eng(val,det_eng,rang(1),rang(2));
                    new_err = sum_eng(err,det_eng,rang(1),rang(2),1);
                    
                    figure
                    hold on
                    surf(X,Y,new_val);
                    
                    whitebg('white')
                    set(gcf,'Color',[1 1 1]); grid on
                    set(gcf,'Position',[ 577   533   599   477])
                    colorbar; shading flat
                    xlabel('[cm]')
                    ylabel('[cm]')
                    zlabel('[cm]')
                    
                    
                    figure
                    hold on
                    surf(X,Y,new_err);
                    whitebg('white')
                    set(gcf,'Color',[1 1 1]); grid on
                    set(gcf,'Position',[ 577   533   599   477])
                    colorbar; shading flat
                    xlabel('[cm]')
                    ylabel('[cm]')
                    zlabel('[cm]')
                    
                    
                end
            else
                ...
            end
        
        if wait == 1
            fprintf('Viewing for DET %s \n',num2str(det_num));
            input('Press enter to continue.');
        end
        else
            ...
        end
    
    det_num = det_num + 1;
    
    if det_num > 10
        det_read = 0;
    end
    
    end
    
    num = num + 1;
end
cd(top_dir)
end

