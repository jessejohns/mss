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