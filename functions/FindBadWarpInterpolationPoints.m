function [bad_point_idx_list, bad_warp_dist_list] = FindBadWarpInterpolationPoints(landmarks_file, affine_trans, interpolation_function, threshold, write, out_file)
% Finds all the landmark pairs that are warped outside of the acceptable
% ranges as detirmined by the warping interpolation function. Has the
% option to change these points to false and write them to an output file.
% landmarks_file is the path to the landmarks file you want to test,
% interplation_function should be the warp interplation function generated
% by CreateWarInterpolation.m, threshold should be the range outside of
% which warping is unacceptable, write should be one to write the file, 0
% otherwise, outut_file should the path to the file you would like to write
% the corrected landmarks to

%% Read in the data 

% landmarks list to be edited
landmarks = readtable(landmarks_file);
rows_false = strcmp(landmarks{:,2}, 'FALSE');

% landmarks for distance calculation
num_landmarks = table2array(landmarks(:, 3:8));
 
if isa(num_landmarks, 'cell')
    num_landmarks = str2double(num_landmarks);
end

LM_landmark_points = num_landmarks(:, 1:3);
EM_landmark_points = num_landmarks(:, 4:6);

%% Apply the ground truth affine transformation
aff_LM_landmark_points = ApplyAffineTrans(LM_landmark_points, affine_trans);

%% Calculate distance from affine transformed points to EM points
warp_dist_list = FindDistances(aff_LM_landmark_points(:,1:3), EM_landmark_points(:, 1:3));

%% Find all landmarks ourside of acceptable warp ranges
good_warping = interpolation_function(EM_landmark_points);
upper_bound = good_warping+threshold;
lower_bound = good_warping-threshold;

% Only change points that are not already false
bad_points = warp_dist_list < lower_bound | upper_bound < warp_dist_list;
bad_points(rows_false,:) = 0; 
landmarks{logical(bad_points),2} = {'FALSE'};

bad_point_idx_list = [find(bad_points), warp_dist_list(logical(bad_points),:)];
bad_warp_dist_list = warp_dist_list(logical(bad_points))-good_warping(logical(bad_points));

%% Write bad_point_numbers to .csv file (optional)
if write == 1
    writetable(landmarks, out_file, 'WriteVariableNames', false);
end
end

