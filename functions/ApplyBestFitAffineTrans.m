function [aff_points,affine_matrix] = ApplyBestFitAffineTrans(points_1,points_2)
% Finds the optimal least-squares solution affine transformation matrix for
% transforming points_1 to points_2, and then applied the transformation to
% points_1. points_1 and points_2 should be point vectors

%% Prepare points affine matrix calculation
points_1 = [points_1, ones(size(points_1,1),1)]';
points_2 = [points_2, ones(size(points_2,1),1)]';

%% Return transformed points and transformation matrix
affine_matrix = points_1/points_2;
aff_points = affine_matrix\points_1;
aff_points = aff_points(1:3,:)';

end

