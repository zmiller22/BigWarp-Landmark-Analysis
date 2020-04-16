function [points] = CreatePointLattice(dims, edge_length)
%TODO clean documentation
% Create an evenly spaced point mesh. dims should be a 3 by 2 matrix where
% the first column contains the starting dimension for x, y, and z (in that
% order) and the second column contains the coorespoinding end points. Will
% round up dimensions to the nearest number into whcih edge_length fits
% into evenly

x_vec = dims(1,1):edge_length:(dims(1,2)+edge_length); 
y_vec = dims(2,1):edge_length:(dims(2,2)+edge_length); 
z_vec = dims(3,1):edge_length:(dims(3,2)+edge_length); 

points = zeros(size(x_vec, 2)*size(y_vec, 2)*size(z_vec, 2), 3);
count = 1;

for x = x_vec
    for y = y_vec
        for z = z_vec
            points(count,1) = x;
            points(count,2) = y;
            points(count,3) = z;
            count = count+1;
        end
    end
end

end

