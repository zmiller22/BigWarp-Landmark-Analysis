function aff_points = ApplyAffineTrans(points,affine_matrix)
% Applies an affine transformation to a set of points according to a given
% affine matrix. points should be a point vector and affine_matrix should
% be an affine transformation of the appropriate dimensions
points = [points, ones(size(points,1),1)]';
aff_points = affine_matrix\points;
aff_points = aff_points(1:3,:)';
end

