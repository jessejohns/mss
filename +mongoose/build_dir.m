function fold_b = build_dir(tar_dir, opt)
%
%  This function builds directory information from a target directory and
%  throws it into a useable string array.
%
%  If opt == 1, it will flip the output array.
%            2, it will 

if exist('opt','var') == 0
    opt = 0;
end

d_list = dir(tar_dir);

% Build directory:
n = 0;

for i = 3:length(d_list)
    
    if opt == 2
        
        n = n + 1;
        fold_b{n} = d_list(i).name;
        
    else
        
        if d_list(i).isdir == 1
            n = n + 1;
            fold_b{n} = d_list(i).name;
        end
        
    end
end


% Flip the order of the array.
if opt == 1
    
    for i = 1:n
        new_fold{i} = fold_b{n-i+1};
    end
    
    if length(new_fold) ~= length(fold_b)
        error('There was a problem...')
    end
    
    fold_b = new_fold;
end
