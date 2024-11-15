# ABR_Analysis_Threshold
Example analysis code for calculating thresholds from ABR waveforms 

## Before running the first time...
Check the Set Directories section to make sure these are right (should work if using the data and analysis straight from github). Put the *Data* folder in the ABR_Analysis_Threshold directory

### If using your own data...
- Make sure the data is organized in the correct file structure. 
- Inside of the main directory, you will see a folder called data. 
- Data contains folders for each condition
- Each condition folder contains a folder for each chinchilla/subject
- Each chinchilla folder contains two folders: Raw and Processed
- The Raw folder should contain all of the p files from the experiment 
- The Processed folder is where the resulting data will be saved to (if `export = 1`)

## Run the code
To run this code, open the *RUN_ABRaudiogram* script. Change the `subj`, `condition`, `export`, and/or `mode` variables depending on the type of analysis you'd like to run

### Files it's running
*ABR_audiogram_chin*
- This file actually does the meat of the analysis. It is run whether youre in single chin mode, pre/post mode, or batch (all chin) mode. 

*+Helper* 
- extra scripts for doing bootstrapping and the xcorr of the matrix

### Plotting Functions
*make_abr_summary_plots* and *plot_preVpost_abr* --> Just for plotting, but can be tweaked if you want to see things differently


###ABR to CSV
This is the set up to make the NEL data in to files compatible with ABRpresto
- Adjust file directories so they grab your data. All p files for one frequency goes in the same csv. 
- After running. you need to change A1 and B1 to *level* and *polarity*, respectively
- code for ABR presto: https://github.com/Regeneron-RGM/ABRpresto