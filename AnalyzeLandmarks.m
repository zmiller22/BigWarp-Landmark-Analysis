clear all;
close all;

%% Set paths to files
%TODO give option to enter all arguments at commandline or through the gui

currentPath = fileparts(mfilename('fullpath'));

functionsPath = fullfile(currentPath, 'functions');
addpath(functionsPath); 

javaPath = fullfile(currentPath, 'java_files/classes');

% TODO set the javapath in a more elegant way (not sure this is worth the
% effort)

javaaddpath(javaPath)
javaaddpath(fullfile(javaPath, '/dependency/ejml-0.24.jar'));
javaaddpath(fullfile(javaPath, '/dependency/opencsv-4.6.jar'));
javaaddpath(fullfile(javaPath, '/dependency/commons-lang3-3.8.1.jar'));
javaaddpath(fullfile(javaPath, '/dependency/imglib2-realtransform-2.2.1.jar'));
javaaddpath(fullfile(javaPath, '/dependency/imglib2-5.6.3.jar'));

% test paths
% landmarksPath = "/home/zack/Desktop/Lab_Work/Code/BigWarp-Landmark-Analysis/test_data/200226_landmarks.csv"
% boundaryPath = "/home/zack/Desktop/Lab_Work/Code/BigWarp-Landmark-Analysis/test_data/200226_landmarks.csv"

% Get the main landmarks file
[landmarksFile, landmarksFolder] = uigetfile('*.csv', 'Select landmark file', 'Select landmark file');
landmarksPath = fullfile(landmarksFolder, landmarksFile);

% Get the boundary file if it exists
[boundaryFile, boundaryFolder] = uigetfile('*.csv', 'Select boundary points file (optional)', 'Select boundary points file (optional)');

if isa(boundaryFile, 'double') || isa(boundaryFolder, 'double')
    boundaryPath = 0;
else 
    boundaryPath = fullfile(boundaryFolder, boundaryFile);
end

dims = input('Please enter the x, y, and z pixel dimensions of the moving volume as a Matlab Vector of the form [x,y,z]: ')
units = input('Please enter the x, y, and z physical dimensions of a voxel in the moving volume as a Matlab Vector of the form [x,y,z]: ')
units = input('Please enter the x, y, and z physical dimensions of a voxel in the fixed volume as a Matlab Vector of the form [x,y,z]: ')
        

%% Read in landmarks

landmarks = Landmarks2Array(landmarksPath);
movingLandmarks = landmarks(:, 1:3);
fixedLandmarks = landmarks(:, 4:6);

% Convert all units from pixels to physical units

%% Create point lattice

dims = input('Please enter the x, y, and z pixel dimensions of the moving volume as a Matlab Vector of the form [x,y,z]: ')
units = input('Please enter the x, y, and z physical dimensions of a voxel in the moving volume as a Matlab Vector of the form [x,y,z]: ')

% Values for John's stacks
%dims=[1123, 427, 636]
%units=[0.43, 0.43, 0.43]

dims_vec = [0, units(1)*dims(1); 0, units(2)*dims(2); 0, units(3)*dims(3)];
edgeLength = 10;
originalLattice = CreatePointLattice(dims_vec, edgeLength);

%% Find points in the area of the transformation 

if boundaryPath ~= 0
    boundaryPoints = Landmarks2Array(boundaryPath);
    a = alphaShape(boundaryPoints(:,1:3));
    in = inShape(a, originalLattice(:,1), originalLattice(:,2), originalLattice(:,3));

    originalLattice = originalLattice(logical(in),:);
end

%% Apply BigWarp transform to the point lattice
fprintf("Calculating nonlinear transform...\n")

TPSLattice = ApplyBigWarpTrans(landmarksPath, originalLattice, 1000, 0.01);

%% Measure non-linear warp distance for landmarks and point lattice
fprintf("Calculating best fit linear transform...")

[linearLandmarks, linearTransMat] = ApplyBestFitAffineTrans(movingLandmarks, fixedLandmarks);
nonlinearLandmarkWarpDists = FindDistances(linearLandmarks, fixedLandmarks);

linearLattice = ApplyAffineTrans(originalLattice, linearTransMat);
nonlinearLatticeWarpDists = FindDistances(linearLattice, TPSLattice);

%% Create plots

figure('color', 'w', 'units','inches','position',[1,1,7,5])
axes('position',[0.3 0.2 0.65 0.65], 'XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on')
hold on;
p = scatter3(TPSLattice(:,1), TPSLattice(:,2), TPSLattice(:,3), 15, nonlinearLatticeWarpDists, 'filled');
colormap('jet');
color_max = max(nonlinearLatticeWarpDists);
caxis([0, color_max]);
colorbar('ylim', [0,color_max]);
p.MarkerFaceAlpha = 0.85;
xlabel('X (pixels)', 'fontname', 'arial', 'fontsize',12)
ylabel('Y (pixels)','fontname','arial','fontsize',12)
zlabel('Z (pixels)', 'fontname', 'arial', 'fontsize',12)
set(gca, 'fontname','arial','fontsize',12)
hold on;
title('Non-adjusted Lattice Warping');
view(45,15);
hold off;

figure('color', 'w', 'units','inches','position',[1,1,7,5])
axes('position',[0.3 0.2 0.65 0.65], 'XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on')
hold on;
p = scatter3(fixedLandmarks(:,1), fixedLandmarks(:,2), fixedLandmarks(:,3), 15, nonlinearLandmarkWarpDists, 'filled');
colormap('jet');
color_max = max(nonlinearLandmarkWarpDists);
caxis([0, color_max]);
colorbar('ylim', [0,color_max]);
p.MarkerFaceAlpha = 0.85;
xlabel('X', 'fontname', 'arial', 'fontsize',12)
ylabel('Y','fontname','arial','fontsize',12)
zlabel('Z', 'fontname', 'arial', 'fontsize',12)
set(gca, 'fontname','arial','fontsize',12)
hold on;
title('Non-adjusted Landmark Warping');
view(45,15);
hold off;

figure('color', 'w', 'units','inches','position',[9,1,7,5])
p = histogram(nonlinearLatticeWarpDists, 20);
xlabel('Non-adjusted residual warp distance of lattice points', 'fontname', 'arial', 'fontsize', 20)
ylabel('Count','fontname','arial','fontsize',12)
set(gca, 'fontname','arial','fontsize',12)
hold on;
line([mean(nonlinearLatticeWarpDists), mean(nonlinearLatticeWarpDists)], ylim, 'LineWidth', 2, 'Color', 'm');

