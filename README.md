mss - matlab serpent scripts
========

MATLAB-based library for data processing of the PSG2/Serpent and MCNP Monte Carlo reactor physics codes.  These
were developed on an as-needed basis with hopes of expanding them; however, my work with Serpent has come mostly
to a close, so I am sharing the scripts with the community.

Please note that many scripts will be broken as I make the transition and others are not in a function form.   jj,29.4.2014

Installation
========

These scripts can be set to the MATLAB path in the following manner:

Set the path to the parent directory containing +mss.

   - When you call a script you will use: mss.Serp_plot_data('.',2,opt)
   

Functionality
========

MCNP_critsearch.m - performs a criticality search on the string "free_parameter" in an input deck.
MCNP_extrat.m     - extracts tally data
MCNP_find_k.m     - extracts the eigenvalue
MCNP_iterator.m   - function require of MCNP_critsearch.m to perfrom the search
MCNP_mesh.m       - extracts and plots mesh data
MCNP_mesh_comp.m  - compares two meshes
Serp_check.m      - statistical checks on Serpent output
Serp_ext_data.m   - Extracts data based on "opt" data structure parameters.
Serp_ext_det.m    - Extracts detector data.
Serp_ext_mat.m    - Extracts material data from depletion calculations.
Serp_iterator.m   - Iterates on a parameters for some conditions.
Serp_plot_data.m  - Quick plotting script that uses _ext_data.m.
Serp_plot_det.m   - " ... _ext_det.m
Serp_plot_his.m   - Plots keff histories if his option is used.
Serp_plot_mat.m   - Quick plotting script that uses _ext_mat.m.  Also contains benchmark data for Takahama-3.
Serp_search_dep.m - Automatically finds _dep.m file in a directory - so one doesn't need the file name.
Serp_search_det.m - Finds all detector files and builds them into a data structure - useful for depletion cases.
Serp_search_res.m - Automatically finds _res.m file in a directory.
Serp_search_his.m - " ... _his.m ... "
Serp_search_res.m - " ... _res.m ... "
Serp_unc_data.m   - Plots data uncertainties for a burnup convergence study.
Serp_unc_mat.m    - Plots material uncertainties for a burnup convergence study.
build_dir.m       - Build directory of input cases.
