function [points] = CreatePointLattice(dims, edge_length)
% Create an evenly spaced point mesh. dims should be a 3 by 2 matrix where
% the first column contains the starting dimension for x, y, and z (in that
% order) and the second column contains the coorespoinding end points

x_vec = dims(1,1):edge_length:dims(1,2); 
y_vec = dims(2,1):edge_length:dims(2,2); 
z_vec = dims(3,1):edge_length:dims(3,2); 

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

