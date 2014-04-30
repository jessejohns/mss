function MCNP_iterator(fileID,work_dir,keff,guess_1,guess_2,use_code,mpi,nprocs)

cd(work_dir)

% Set MPI option:
% 1 = on, 0 = off - go to system statements to change number of processors.

% Some initial sets:
s(1) = guess_1;
s(2) = guess_2;
i = 0;

dT = 1.0;

damp = .75;

%% Start loop:

while dT > 0.001

    i = i+1;
    
delete work_input work_output runtpe srctp
diary work_input

%% Open/Read/Rewrite input file:

id = fopen(fileID);

if (id < 0)
    error('Could not open output file.'); 
end

in_line = fgetl(id);

while ischar(in_line); 
    
    cur_line = findstr(in_line,'free_parameter');
    
    if cur_line > 0;
        new_line = strrep(in_line,'free_parameter',num2str(s(i)));
        fprintf('%s \n',new_line);
    else
        fprintf('%s \n',in_line);
    end
    
    in_line = fgetl(id);
end

fclose(id);

diary off

%% Run input:

if mpi == 1;
    if use_code == 1;
        evalstring = ['!mcnp5_omp tasks ' num2str(nprocs) ' i=work_input o=work_output'];
        eval(evalstring)
    else
        !mcnpx i=work_input o=work_output
    end
else
    if use_code == 1;
        !mcnp5_omp i=work_input o=work_output
    else
        !mcnpx i=work_input o=work_output
    end
end

%% Find K_eff:

[k(i) dk(i)] = MCNP_find_k('work_output');


if i > 1;
    s(i+1) = s(i) + (keff-k(i))*(s(i)-s(i-1))/(k(i)-k(i-1))*damp;
end

dT(i) = abs(keff - k(i));

if i > 1;
    rat(i) = dT(i)/(k(i)-k(i-1));
end

end

%% Plot convergence:
whitebg('white')
set(gcf,'Color',[1 1 1])

[AX,H1,H2] = plotyy(1:length(k),k,1:length(k),s(1:length(s)-1));

hold on

xlabel('Iteration')
set(get(AX(1),'Ylabel'),'String','K_e_f_f') 
set(get(AX(2),'Ylabel'),'String','Free Parameter') 
set(H1,'LineStyle','--')

legend('K_e_f_f','Free Parameter','Location','southeast')

warndlg('Check input/output files for final results','Convergence completed!')
 
end