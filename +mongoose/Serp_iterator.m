function Serp_iterator(fileID,work_dir,keff,guess_1,guess_2,mpi)

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
    
delete work_input 
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

%% Manual input:
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                    MANUAL INPUT FILE
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% If an input file is being manually inputed, ie: a set of surfaces defined
% by some percentage of removal, then use the example as shown below and
% comment the "Open input" from above.

%
% fprintf('This is a sphere in vacuum     \n');
% fprintf('c                              \n');
% fprintf('c                              \n');
% fprintf('1  1  -15  -1 imp:n=1          \n');
% fprintf('2  0        1 imp:n=0          \n');
% fprintf('                               \n');
% fprintf('c                              \n');
% fprintf('1  so  %2.5f                  \n',s(i));
% fprintf('                               \n');
% fprintf('c                              \n');
% fprintf('kcode 1200 1.0 50 500          \n');
% fprintf('ksrc 0 0 0                     \n');
% fprintf('mode n                         \n');
% fprintf('m1  92235 1                    \n');
%
% diary off

%% Run input:

if exist('mpi','var')
        evalstring = ['!sss -mpi ' num2str(mpi) ' work_input'];
        eval(evalstring)
else
    !sss work_input
end

%% Find K_eff:

work_input_res


if i > 1;
    s(i+1) = s(i) + (keff-ABS_KEFF(i,1))*(s(i)-s(i-1))/(ABS_KEF(i,1)-ABS_KEFF(i-1,1))*damp;
end

dT(i) = abs(keff - ABS_KEFF(i,1));

if i > 1;
    rat(i) = dT(i)/(ABS_KEFF(i,1)-ABS_KEFF(i-1,1));
end

end

%% Plot convergence:
whitebg('white')
set(gcf,'Color',[1 1 1])

[AX,H1,H2] = plotyy(1:length(ABS_KEFF(:,1)),ABS_KEFF(:,1),1:length(ABS_KEFF(:,1)),s(1:length(s)-1));

hold on

xlabel('Iteration')
set(get(AX(1),'Ylabel'),'String','K_e_f_f') 
set(get(AX(2),'Ylabel'),'String','Free Parameter') 
set(H1,'LineStyle','--')

legend('K_e_f_f','Free Parameter','Location','southeast')

warndlg('Check input/output files for final results','Convergence completed!')
 
end
