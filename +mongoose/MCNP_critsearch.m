function MCNP_critsearch

if isdeployed
    old = pwd;
    cd(ctfroot);
end

[file, dir] = uigetfile('*.*','Select MCNP input file');

prompt={'Converge Keff to:', 'First guess:', 'Second guess:'};
defans={'1.0', '10', '20'};
fields = {'keff','s1', 's2'};

info = inputdlg(prompt, 'User inputs.', 1, defans);

if ~isempty(info);
    info = cell2struct(info,fields);
    keff = str2double(info.keff);
    guess_1 = str2double(info.s1);
    guess_2 = str2double(info.s2);
    
    use_code = menu('Which code is the file compatible with?','MCNP5','MCNPX');
    mpi = menu('Would you like to use MPI?','Yes.','No.');
    
    if mpi == 1
        nprocs = menu('How many processors?','1','2','3','4','5','6');
    else
        nprocs = 0;
    end
    
    if isdeployed
        cd(old); end
    
    % Run fitting script:
    
    MCNP_iterator(fullfile(dir,file),dir,keff,guess_1,guess_2,use_code,mpi,nprocs);
    
end

end