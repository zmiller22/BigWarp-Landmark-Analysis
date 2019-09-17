function dist_list = FindDistances(points_1,points_2)
% Calculate distances between each point in points_1 and points_2, which
% should both be point vectors

dist_list = sqrt(sum((points_1-points_2).^2, 2));
end

