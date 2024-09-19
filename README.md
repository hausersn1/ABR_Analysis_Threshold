# ABR_Analysis_Threshold
Example analysis code for calculating thresholds from ABR waveforms 

## Before running the first time...
Check the Set Directories section to make sure these are right (should work if using the data and analysis straight from github)

### If using your own data...
Make sure the data is organized in the correct file structure. 
Inside of the main directory, you will see a folder called data. 
Data contains folders for each condition
Each condition folder contains a folder for each chinchilla/subject
Each chinchilla folder contains two folders: Raw and Processed
The Raw folder should contain all of the p files from the experiment 
The Processed folder is where the resulting data will be saved to (if `export = 1`)

## Run the code
To run this code, open the RUN_ABRaudiogram script. 
change the `subj`, `condition`, `export`, and/or `mode` variables depending on the type of analysis you'd like to run

### Files it's running
*ABR_audiogram_chin*
This file actually does the meat of the analysis. It is run whether youre in single chin mode, pre/post mode, or batch (all chin) mode. 
