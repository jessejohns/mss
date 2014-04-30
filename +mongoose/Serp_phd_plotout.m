function Serp_phd_plotout(fileID)

G = Serp_phd_readout(fileID);

% G(step,iter,val)

opt.plot = 1;

Serp_plot_data({'.'},1,opt)
