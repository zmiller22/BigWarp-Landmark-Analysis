function [bad_point_idx_list, bad_point_dist_list] = FindBadNNPoints(landmarks_file, nn_dist_list, nn_idx_list, nn_mesh_points, filter_width, write, out_file)
% Find all points in nn_mesh_points that have an average nearest neighbor
% metric that is more than 2 standard deviations away from the mean, and
% then find and set to false the landmark points closest to that
% nn_mesh_point. landmarks_file should be the path to the landmarks file,
% nn_dist_list should be the list of nn distances for each point in
% nn_mesh_points, nn_idx_list should be the cooresponding index for each
% point in nn_mesh_points, nn_mesh_points should be the nX3 list of points
% that you have nn distances for, write should be equal to 1 if you want to
% write the file (optional), and out_file shoudl be the path to the output
% file you wish to write to

% TODO fix bad_point_dist_list as it currently does not match the idx list

%% Read in the data
landmarks = readtable(landmarks_file);
EM_points = table2array(landmarks(:, 6:8));



%% Find outliers in nn_mesh_points
sd = std(nn_dist_list);
mn = mean(nn_dist_list);
upper_threshold = mn+filter_width*sd;
lower_threshold = mn-filter_width*sd;

% This logical will be used to select the proper idxs in nn_idx_list
bad_idx_logical = nn_dist_list>upper_threshold | nn_dist_list<lower_threshold;

bad_mesh_points = nn_mesh_points(nn_idx_list(bad_idx_logical, 1),:);

%% Find the EM_points closest to outlier points
[bad_point_idx_list, bad_point_dist_list] = knnsearch(EM_points, bad_mesh_points);
bad_point_idx_list = unique(bad_point_idx_list);

rows_true = strcmp("TRUE", landmarks{bad_point_idx_list, 2});
bad_point_idx_list = bad_point_idx_list(rows_true);

landmarks{bad_point_idx_list,2} = {'FALSE'};

%% Write bad_point_numbers to .csv file (optional)
if write == 1
    writetable(landmarks, out_file, 'WriteVariableNames', false);
end


end

