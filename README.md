# README
## Note, this repo is not funcitonal in its current form (The JAVA dependencies are not included in the repo). Look for this to be fixed in a future release.

# BigWarp-Landmark-Analysis
Provides tools for visualizing and quantifying transformations generated in FIJI BigWarp. Also allows for removal of landmark points that are unlikely to be correct based on the transformation generated by a small set of high quality landmarks.

# Usage
This code was developed with the intention of use by the Engert lab only. While others are welcome (and encouraged!) to use it, the code and its accompanying documentation is specifically written for members of the Engert lab, and therefore may not contain adequate functionality/documentation for other users. All metrics and plots are explained in the pdfs in the repository.

TODO write a guide to the plots

TODO explain the use of LM and EM in the code

This software package uses three main files:
 * A landmark .csv file in the format generated by the FIJI BigWarp tool that contains the points being used to generate the transformation (required)
 * A "ground truth" landmark .csv file in the format generated by the FIJI BigWarp tool (optional). These should be a set of high confidence landmarks that will be used to estimate the amount of non-linear warping present between the two images for calculating the adjusted residual warping metric.
 * A "boundary points" landmark.csv file in the format generated by the FIJI BigWarp tool (optional). These landmarks will be used to select only points in the image that are in the area of the transformation. There are basically three ways to do this. The default is to not include any boundary point file at all, in which case the program applies the transform and calculates metrics for the entire point lattice with the dimensions input by the user. Another option is to simply use the main landmark file itself, in which case a bounding shape is drawn around all the points in the landmarks file and only points that are within that bounding shape are transformed and included in metrics calculations. Lastly, the user may opt to provide a landmarks file specifically created to surround a region of interest, in which case a bounding shape will be calculated and used to select points in the same way as the previous option.


To use this software package, open the file “AnalyzeLandmarks.m” in matlab. Before running the program, you may want to adjust a few hardcoded values. The first are x_dims, y_dims, and z_dims located at lines 80-82. Set these values to equal the dimensions of the moving image you used in BigWarp. Lastly, if you plan on using the transformation metrics to remove suspected “bad” points, you should also set the threshold located at line 143 to your desired value (default 15). After you have set these variables to your desired values, you can then save your changes and run the program. 

When you run the program, you will first be prompted to select your landmark file. This is not optional. Next, you will be prompted to select your ground truth landmark file if you have one. If you do not wish to do so or do not have one, simply exit the pop-up window without selecting a file. Next, you will be prompted to select your boundary points. Again, if you do not wish to do so just exit the window. Note that you may also choose to uncomment lines 32-34 and instead hardcode the paths in to avoid having to select them each time you run the program.

If you did not enter a file path for a ground truth landmarks file, then you will see the plots pop up shortly. If you did enter a ground truth landmarks file, you will be asked if you would like to deactivate outlying points, which will be done using the adjusted residual warp distances and the threshold value you chose in the code. If you would not like to do so, enter ‘n’ and the plots will appear shortly. If you would like to do so, enter ‘Y’. You will lastly be prompted to select the folder that you would like the edited landmarks file titled “fixed_points.csv” to be saved in (note that if this folder already contains a file with this name, the file will be written over). Once you have selected a folder your plots will appear shortly. You may also choose to uncomment line 148 and enter a hardcoded file path.

TODO Need to find a clean way to add all the java dependencies to the github repo (the raw dependencies are too big to upload to github, even when they are zipped).
