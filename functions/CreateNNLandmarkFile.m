function CreateNNLandmarkFile(mesh_points, mesh_points_trans, nn_dist_list, nn_idx_list, filter_width, out_file)
% Creates a landmark file using mesh_points that had the least change in
% nearest neighbor distance during the transformation. mesh_points should
% be a perfect point mesh, mesh_points_trans should be the transformed mesh
% points, nn_dist_list should contain the nearest neighbors distances for
% all relevent points in mesh_points_trans, nn_idx_list should contain the
% cooresponding indicies in mesh_points_trans for each value in
% nn_dist_list, filter_width should be the number of standard deviations
% away from the mean nn distastance a distance must be within to still be
% included, out_file should be the path to the to the landmark csv file you
% would like to write out to

%% Find good points in mesh_points_trans
sd = std(nn_dist_list);
mn = mean(nn_dist_list);
upper_threshold = mn+filter_width*sd;
lower_threshold = mn-filter_width*sd;

% This logical will be used to select the proper idxs in nn_idx_list
good_idx_logical = nn_dist_list<upper_threshold & nn_dist_list>lower_threshold;

good_point_idx_list = nn_idx_list(good_idx_logical, 1);
good_points = [mesh_points(good_point_idx_list,:), mesh_points_trans(good_point_idx_list,:)];

point_nums = 0:size(good_point_idx_list,1)-1;
point_nums = string(point_nums');
prefix = "Pt-";
point_nums = strcat(prefix, point_nums);

use_points = ["TRUE"];
use_points = repmat(use_points, size(good_points,1), 1);



new_landmarks = table(point_nums, use_points, good_points(:,1), good_points(:,2), good_points(:,3), good_points(:,4), good_points(:,5), good_points(:,6)); 

writetable(new_landmarks, out_file, 'WriteVariableNames', false);
end

