function [outputArg1,outputArg2] = GetNNDistances(points_to_test, buffer_point_lattice, nn_idx_list)
%UNTITLED13 Summary of this function goes here

% Scaling factors for going from pixels to microns
x_scale = 0.5;
y_scale = 0.5;
z_scale = 0.5;

% Scaling factor for going from LM to EM space
LM_to_EM_scale = 1.2745;

% Need to rethink how this loop should work
for test = 1:size(points_to_test,1) 
    d = 0;
    d_um = 0;
    for i = 1:k
        p_1 = points_to_test(nn_idx_list(test,1),:);
        p_2 = points_trans(nn_idx_list(test,i),:);
        d = d+sqrt(sum((p_1 - p_2).^2));
        
        p_1_um = [p_1(:,1)*x_scale, p_1(:,2)*y_scale, p_1(:,3)*z_scale];
        p_2_um = [p_2(:,1)*x_scale, p_2(:,2)*y_scale, p_2(:,3)*z_scale];
        d_um = d_um+sqrt(sum((p_1_um - p_2_um).^2));
    end
    new_nn_dist_list(1,test) = d/6;
    um_nn_dist_list(1,test) = d_um/6;
end

new_nn_dist_list = (new_nn_dist_list/LM_to_EM_scale);
outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

