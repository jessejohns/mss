function MCNP_mesh(fold, fileID, loc, ene)
%% MCNP_mesh(fold, fileID, loc)
%
%  This function plots an MCNP5 'meshtal' file in the 'col' format.  The
%  slice function is used to plot the slices at their maximum x, y, and z
%  locations, by default.
%
%  Inputs:
%
%  fold, the directory in which to find the meshtal input.
%
%  fileID, the name of the meshtal input.
%
%  loc, a 2D matrix that has location of the plane which to slice given by
%       the perpendicular location with the axis.
%       [ x1 ... xn; y1 ... yn; z1 ... zn ];
%
%  ene, if there are more than 1, this indexes which energy interval to
%       plot.
%
%% Testing variables:
% fold = '/home/jesse/Simulations';
% fileID = 'meshtal';
% ene = 1;

%% NOTES:
%  This so can only handle 1 mesh in the meshtal input.
%  Need to implement a better loading feature.

%% Start

cur_dir = pwd;
cd(fold);

%% Open file

id = fopen(fileID);

if (id < 0)
    error('Could not open output file.');
end

in_line = fgetl(id);

%% Read Data

cap_da = 0;

% Find tally number and type:

while ischar(in_line) > 0;
    
    % Find tally number
    if findstr(in_line,'Mesh Tally Number')
        nex_spl = regexp(in_line,' ','split');
        tal_num = nex_spl(6);
        in_line = fgetl(id);
    end
    
    % Find boundaries:
    if findstr(in_line,'Tally bin boundaries:');
        for i = 1:4
            in_line = fgetl(id);
            type_set = textscan(in_line,'%s');
            temp = type_set{1};
            if strcmp(temp{1},'X')
                for j = 3:length(temp);
                    X_v(j-2,1) = str2double(temp{j});
                end
            elseif strcmp(temp{1},'Y')
                for j = 3:length(temp);
                    Y_v(j-2,1) = str2double(temp{j});
                end
            elseif strcmp(temp{1},'Z')
                for j = 3:length(temp);
                    Z_v(j-2,1) = str2double(temp{j});
                end
            elseif strcmp(temp{1},'Energy')
                for j = 4:length(temp);
                    E_v(j-3,1) = str2double(temp{j});
                end
            end
        end
        Nx = length(X_v);
        Ny = length(Y_v);
        Nz = length(Z_v);
        Ne = length(E_v);
    end
    
    % Generate data matrix
    
    if findstr(in_line,'Energy')
        if findstr(in_line,'Rel Error')
            cap_da = 1;
        else
            ...
        end
    end
    
    if cap_da == 1;
        R_vec = zeros(Nx-1,Ny-1,Nz-1,Ne);
        E_vec = R_vec;
        R_tot = zeros(Nx-1,Ny-1,Nz-1);
        E_tot = R_tot;
        
        idx = 0;
        is_done = 0;
        
        i_x = 1;
        j_y = 1;
        k_z = 1;
        m_e = 1;
        
        while is_done == 0;
            
            A = textscan(in_line,'%f%f%f%f%f%f');
            
            if A{1} > 0
                
                R_vec(i_x,j_y,k_z,m_e) = A{5};
                E_vec(i_x,j_y,k_z,m_e) = A{6};
                
                k_z = k_z + 1;
                
                if k_z == Nz;
                    k_z = 1;
                    j_y = j_y + 1;
                end
                
                if j_y == Ny;
                    j_y = 1;
                    i_x = i_x + 1;
                end
                
                if i_x == Nx;
                    i_x = 1;
                    m_e = m_e + 1;
                end
                
            else
                A = textscan(in_line,'%s%f%f%f%f%f');
                
                if idx == 0
                    i_x = 1;
                    j_y = 1;
                    k_z = 1;
                    idx = 1;
                end
                
                if strcmp(A{1},'Total')
                    
                    R_tot(i_x,j_y,k_z) = A{5};
                    E_tot(i_x,j_y,k_z) = A{6};
                    
                    k_z = k_z + 1;
                    
                    if k_z == Nz;
                        k_z = 1;
                        j_y = j_y + 1;
                    end
                    
                    if j_y == Ny;
                        j_y = 1;
                        i_x = i_x + 1;
                    end
                    
                    if i_x == Nx;
                        i_x = 1;
                    end
                    
                end
            end
            in_line = fgetl(id);
            
            if ischar(in_line) > 0
            else
                break
            end
        end
        
        cap_da = 0;
    else
        in_line = fgetl(id);
    end
    
end

%% Organize Data

X = zeros(Nx-1,1);
Y = zeros(Ny-1,1);
Z = zeros(Nz-1,1);

for i = 1:Nx-1
    X(i) = (X_v(i+1)+X_v(i))/2;
end

for i = 1:Ny-1
    Y(i) = (Y_v(i+1)+Y_v(i))/2;
end

for i = 1:Nz-1
    Z(i) = (Z_v(i+1)+Z_v(i))/2;
end

%% Plot

R = R_vec(:,:,:,ene);
err = E_vec(:,:,:,ene);
loc = [10 60; 132.5 132.5; 25 60];

if exist('loc','var')
    figure
    slice(X,Y,Z,R,loc(1,:),loc(2,:),loc(3,:),'cubic')
    
    hold on
    whitebg('white')
    set(gcf,'Color',[1 1 1]); grid on
    set(gcf,'Position',[118   481   719   441])
    colorbar; shading flat
    xlabel('x-direction [cm]')
    ylabel('y-direction [cm]')
    zlabel('z-direction [cm]')
else
    slice_max(X,Y,Z,R,err)
end

cd(cur_dir);
