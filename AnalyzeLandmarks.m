clear all;
close all;

%% Set paths to files

currentPath = fileparts(mfilename('fullpath'));

functionsPath = fullfile(currentPath, 'functions');
addpath(functionsPath);

[landmarksFile, landmarksFolder] = uigetfile('*.csv', 'Select landmark file', 'Select landmark file');
landmarksPath = fullfile(landmarksFolder, landmarksFile);

[GtLandmarksFile, GtLandmarksFolder] = uigetfile('*.csv', 'Select ground truth landmark file (optional)', 'Select ground truth landmark file (optional)');
GtLandmarksPath = fullfile(GtLandmarksFolder,GtLandmarksFile);

if isa(GtLandmarksFile, 'double') || isa(GtLandmarksFolder, 'double')
    GtLandmarksPath = 0;
else 
    GtLandmarksPath = fullfile(GtLandmarksFolder, GtLandmarksFile);
end

[boundaryFile, boundaryFolder] = uigetfile('*.csv', 'Select boundary points file (optional)', 'Select boundary points file (optional)');

if isa(boundaryFile, 'double') || isa(boundaryFolder, 'double')
    boundaryPath = 0;
else 
    boundaryPath = fullfile(boundaryFolder, boundaryFile);
end

% Optional hardcoded paths
% landmarksPath = fullfile('C:\Users\TracingPC1\Desktop\BIGWARP\zack_transforms\190712_transform\landmarks_190712.csv');
% boundaryPath = fullfile('C:\Users\TracingPC1\Desktop\BIGWARP\zack_transforms\190712_transform\common\boundary_points.csv');
% GtLandmarksPath = fullfile('C:\Users\TracingPC1\Desktop\BIGWARP\zack_transforms\ground_truth_landmarks\ground_truth_landmarks.csv');


%% Give user option to clean bad points

if GtLandmarksPath ~= 0
    while true
        prompt = "Would you like to deactivate outlying points (Y/n)? : ";
        str = input(prompt, 's');

        if str == 'Y'
            fprintf("You chose to deactivate outlying points");
            cleanPoints = true;
            break;

        elseif str == 'n' 
            fprintf("You chose not to deactivate outlying points");
            cleanPoints = false;
            break;

        else
            fprintf("You selected an invalid option, please input 'Y' for yes or 'n' for no \n")  
        end
    end
else 
    cleanPoints = false;
end
        

%% Read in landmarks

landmarks = Landmarks2Array(landmarksPath);
LmLandmarks = landmarks(:, 1:3);
EmLandmarks = landmarks(:, 4:6);

if GtLandmarksPath ~= 0
    gtLandmarks = Landmarks2Array(GtLandmarksPath);
    gtLmLandmarks = gtLandmarks(:, 1:3);
    gtEmLandmarks = gtLandmarks(:, 4:6);
end

%% Create point lattice

% TODO add in the option for the user to set these values during runtime

% Adjust these values to match the dimensions of your moving volume
x_dims = 1620;
y_dims = 820;
z_dims = 500;

dims = [0, x_dims; 0, y_dims; 0, z_dims];
edgeLength = 20;
pointLattice = CreatePointLattice(dims, edgeLength);

%% Find points in the area of the transformation 

if boundaryPath ~= 0
    boundaryPoints = Landmarks2Array(boundaryPath);
    a = alphaShape(boundaryPoints(:,1:3));
    in = inShape(a, pointLattice(:,1), pointLattice(:,2), pointLattice(:,3));

    pointLatticeIn = pointLattice(logical(in),:);
else 
    a = alphaShape(pointLattice);
    in = inShape(a, pointLattice(:,1), pointLattice(:,2), pointLattice(:,3));

    pointLatticeIn = pointLattice(logical(in),:);
end

%% Apply transform to the pointLattice

javaPath = fullfile(currentPath, 'java_files\classes');

% TODO set the javapath in a more elegant way (not sure this is worth the
% effort)

javaaddpath(javaPath)
javaaddpath(fullfile(javaPath, '\dependency\ejml-0.24.jar'));
javaaddpath(fullfile(javaPath, '\dependency\opencsv-4.6.jar'));
javaaddpath(fullfile(javaPath, '\dependency\commons-lang3-3.8.1.jar'));
javaaddpath(fullfile(javaPath, '\dependency\imglib2-realtransform-2.2.1.jar'));
javaaddpath(fullfile(javaPath, '\dependency\imglib2-5.6.3.jar'));

transPointLatticeIn = ApplyBigWarpTrans(landmarksPath, pointLatticeIn, 200, 0.1);

%% Measure non-linear warp distance for landmarks and point lattice

if GtLandmarksPath == 0
    [affLmLandmarks, affMatrix] = ApplyBestFitAffineTrans(LmLandmarks, EmLandmarks);
    landmarkWarpDistList = FindDistances(affLmLandmarks, EmLandmarks);

    affPointLatticeIn = ApplyAffineTrans(pointLatticeIn, affMatrix);
    latticeWarpDistListIn = FindDistances(affPointLatticeIn, transPointLatticeIn);

else
    interpFunction = CreateWarpInterpolation(GtLandmarksPath, 'linear');
    estWarpDistListIn = abs(interpFunction(transPointLatticeIn));
    
    [~, gtAffMatrix] = ApplyBestFitAffineTrans(gtLmLandmarks, gtEmLandmarks);
    
    affLmLandmarks = ApplyAffineTrans(LmLandmarks, gtAffMatrix);
    landmarkWarpDistList = FindDistances(affLmLandmarks, EmLandmarks);
    
    affPointLatticeIn = ApplyAffineTrans(pointLatticeIn, gtAffMatrix);
    latticeWarpDistListIn = FindDistances(affPointLatticeIn, transPointLatticeIn);
    latticeWarpDistListIn = abs(latticeWarpDistListIn-interpFunction(transPointLatticeIn));
end

if cleanPoints
    threshold = 15; % adjust this value to desired threshold value
    outputFolderPath = uigetdir('title', 'Please select the output folder');
    outputFilePath = fullfile(outputFolderPath, '/fixed_points.csv');
    
    % Optional hardcoded path
    % outputFilePath = fullfile('C:\Users\TracingPC1\Desktop\BIGWARP\zack_transforms\transform_series_3\test_fixed_points');
    
    [badPointIdxList, badWarpDistList] = FindBadWarpInterpolationPoints(landmarksPath, gtAffMatrix, interpFunction, threshold, 1, outputFilePath);
end

%% Create plots

if GtLandmarksPath == 0
    figure('color', 'w', 'units','inches','position',[1,1,7,5])
    axes('position',[0.3 0.2 0.65 0.65], 'XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on')
    hold on;
    p = scatter3(transPointLatticeIn(:,1), transPointLatticeIn(:,2), transPointLatticeIn(:,3), 15, latticeWarpDistListIn, 'filled');
    colormap('jet');
    color_max = max(latticeWarpDistListIn);
    caxis([0, color_max]);
    colorbar('ylim', [0,color_max]);
    p.MarkerFaceAlpha = 0.85;
    xlabel('X (pixels)', 'fontname', 'arial', 'fontsize',12)
    ylabel('Y (pixels)','fontname','arial','fontsize',12)
    zlabel('Z (pixels)', 'fontname', 'arial', 'fontsize',12)
    set(gca, 'fontname','arial','fontsize',12)
    hold on;
    title('Non-adjusted warp field');
    view(45,15);
    hold off;

    figure('color', 'w', 'units','inches','position',[9,1,7,5])
    p = histogram(latticeWarpDistListIn, 20);
    xlabel('Non-adjusted residual warp distance of lattice points', 'fontname', 'arial', 'fontsize', 20)
    ylabel('Count','fontname','arial','fontsize',12)
    set(gca, 'fontname','arial','fontsize',12)
    hold on;
    line([mean(latticeWarpDistListIn), mean(latticeWarpDistListIn)], ylim, 'LineWidth', 2, 'Color', 'm');

else
    figure('color', 'w', 'units','inches','position',[1,1,7,5])
    axes('position',[0.3 0.2 0.65 0.65], 'XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on')
    hold on;
    p = scatter3(transPointLatticeIn(:,1), transPointLatticeIn(:,2), transPointLatticeIn(:,3), 15, latticeWarpDistListIn, 'filled');
    colormap('jet');
    color_max = max(latticeWarpDistListIn);
    caxis([0, color_max]);
    colorbar('ylim', [0,color_max]);
    p.MarkerFaceAlpha = 0.85;
    xlabel('X (pixels)', 'fontname', 'arial', 'fontsize',12)
    ylabel('Y (pixels)','fontname','arial','fontsize',12)
    zlabel('Z (pixels)', 'fontname', 'arial', 'fontsize',12)
    set(gca, 'fontname','arial','fontsize',12)
    hold on;
    title('Adjusted warp field');
    view(45,15);
    hold off;

    figure('color', 'w', 'units','inches','position',[9,1,7,5])
    p = histogram(latticeWarpDistListIn, 20);
    xlabel('Adjusted residual warp distance of lattice points', 'fontname', 'arial', 'fontsize', 20)
    ylabel('Count','fontname','arial','fontsize',12)
    set(gca, 'fontname','arial','fontsize',12)
    hold on;
    line([mean(latticeWarpDistListIn), mean(latticeWarpDistListIn)], ylim, 'LineWidth', 2, 'Color', 'm');

    figure('color', 'w', 'units','inches','position',[17,1,7,5])
    p = histogram(estWarpDistListIn, 20);
    xlabel('Non-adjusted residual warping of lattice points estimated from ground truth', 'fontname', 'arial', 'fontsize', 20)
    ylabel('Count','fontname','arial','fontsize',12)
    set(gca, 'fontname','arial','fontsize',12)
    hold on;
    line([mean(estWarpDistListIn), mean(estWarpDistListIn)], ylim, 'LineWidth', 2, 'Color', 'm');
end 
