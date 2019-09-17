function F = CreateWarpInterpolation(gt_landmarks_path, interpolation_type)
% Given a set of high confidence landmarks, this function measures the
% amount of warping for each landmark pair, and then creates an
% interpolation function that gives the "acceptable warping" at each point
% in the space. landmarks_path should be the path to the high confidence
% landmarks file, and interpolation type should be one of the
% interpolation options for MATLAB's scatterdInterpolant function

% Read in the points from the landmark file
landmarks = Landmarks2Array(gt_landmarks_path);
LM_landmarks = landmarks(:,1:3);
EM_landmarks = landmarks(:,4:6);

% Caculate distance from best-fit affine transfromation for each landmark
[affine_LM_landmarks, affine_matrix] = ApplyBestFitAffineTrans(LM_landmarks, EM_landmarks);
dist = FindDistances(affine_LM_landmarks, EM_landmarks);

% Create interpolant function
F = scatteredInterpolant(EM_landmarks, dist, interpolation_type);
end

