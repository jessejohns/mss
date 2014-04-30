function Corium_opt_check(prefix,input_file)
% This is specfic to my corium simulations.  It will remove files, so don't
% use it on anything else..


NAN = 0;
INF = 0;

eofs = 0;
ind = 0;
count = 0;
sucess = 0;
fail = 0;

while eofs == 0
    
    %% List of folders to be searched:
    ind = ind + 1;
    
    fold = [prefix num2str(ind)];
    f_find = exist(fold,'dir');
    
    if f_find > 0
        
        count = count + 1;
        
        %% Pull data
        clear idx BURN_DAYS ABS_KEFF
        
        cd(fold);
        res_string = [input_file '_res'];
        eval(res_string);
        
        !rm -f -r *.out
        
        cd ..
        
        k_string = ['Keff_data_' num2str(count) '(:,1) = ABS_KEFF(:,1);'];
        b_string = ['Burn_days_' num2str(count) '(:,1) = BURN_DAYS(:,1);'];
        eval(k_string);
        eval(b_string);
        
        %% Determine constraints:
        
        d_string = ['max(Keff_data_' num2str(count) '(:,1)) - Keff_data_' num2str(count) '(1,1);'];
        d_k = eval(d_string);
        
        l_string = ['interp1(Keff_data_' num2str(count) '([10:length(Keff_data_' ...
            num2str(count) ')],1), Burn_days_' num2str(count) '([10:length(Keff_data_'...
            num2str(count) ')],1)/365,Keff_data_' num2str(count) '(1,1));'];
        irr_time = eval(l_string);
        
        if irr_time > 10
            sucess = sucess + 1;
            %% Rename folder:
            new_fold = ['Set-' num2str(sucess)];
            movefile(fold,new_fold)
            
            FOM(sucess) = abs(irr_time*(1-d_k)-10);
            
            diary FOM_data
            fprintf('%s \t %s \t %5.3f   %5.3f \n',new_fold,FOM(sucess),d_k,irr_time);
            diary off
            
        else
            fail = fail + 1;
            %% Rename folder:
            new_fold = ['Fail-' num2str(fail)];
            movefile(fold,new_fold)
        end
        
    elseif ind == 1000;
        break
    else
        ...
    end

end
