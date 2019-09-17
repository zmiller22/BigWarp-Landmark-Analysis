function landmarks = Landmarks2Array(in_file)
% Reads in a landmarks file directly to an array while ignoring landmark
% points marked as 'FALSE'. in_file should be the path to the landmark file
% you want to read in

landmarks = readtable(in_file);
rows_to_delete = strcmp(landmarks{:,2}, 'FALSE') | strcmp(landmarks{:,2}, 'false');
landmarks(rows_to_delete, :) = [];
landmarks = table2array(landmarks(:,3:8));

if isa(landmarks, 'cell')
    landmarks = str2double(landmarks);
end

end

