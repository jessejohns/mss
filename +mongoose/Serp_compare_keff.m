function Serp_compare_keff()

%% TODO
%
%  Calculate errors
%    - Maybe include this in Serp_plot_keff instead of seperate...
%    - Or reduce complexity by just saving data file...
%  Compare isotopics as well...
%    - Run through ZAID, divide by ten, remainder, plot.

%% Main script

main_dir = '.';
dir = {'Serp1' 'Serp2'};

leg_1 = {'Serpent1 Base' 'Serpent2 Base' 'MCNPX'};

cur_dir = pwd;
cd(main_dir)

Serp_plot_keff(dir,1)

MCNPX_data

timemc = MC(:,3)/365;
keffmc = MC(:,5);
bumc = MC(:,end-1);

figure(1)
plot(timemc,keffmc,'k-.')
legend(leg_1)

figure(2)
plot(bumc,keffmc,'k-.')
legend(leg_1)

cd(cur_dir)

end