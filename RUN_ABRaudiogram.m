%% DPswept Analysis - Set up Files

clear;
set(0,'defaultfigurerenderer','opengl')

%% Choose Chin and Run type
subj = 'Q442';
condition = 'Baseline';

export = 1; % Save data? 
mode = 0;   % 0 - Process single chin,
            % 1 - Process and Plot single chin pre/post,
            % 2 - batch process all
            % 3 - Plot Processed Group Data
            % 4 - Only Plot pre/post

%if processing click, put a 0 in freqs
freqs = [500,1e3,2e3,4e3,8e3];

%% Set Directories      
% if filesep is not in your current version of matlab, set it here: 
% filesep = '\'; 
current_dir = pwd;
data_dir = [current_dir, filesep, 'Data', filesep]; 

%% Run analysis 
switch mode
    case 0
        disp("Processing Single Chin...");
        suffix = [condition, filesep, subj, filesep];
        datapath = [data_dir,suffix];
        
        ABR_audiogram_chin;      
        
    case 1
        disp("Processing Single Chin Pre vs Post...")
        cd(data_dir)
        chins_cond = dir(sprintf('*/%s/', subj));
        cond_cell = cell(size(chins_cond));
        for folder_i = 1:size(chins_cond,1)
            cond_cell(folder_i,1) = extractBetween(chins_cond(folder_i).folder,'Data\',sprintf('%s%s', filesep, subj));
        end
        [conds,~,ind] = unique(cond_cell);
        cd(current_dir);
        
        for c = 1:size(conds,1)
            condition = conds{c}; 
            suffix = [condition, filesep,subj,filesep];
            datapath = [data_dir,suffix];
            ABR_audiogram_chin;
        end
        cd(current_dir)
        plot_preVpost_abr; 
        
    case 2 % Process ALL data for ALL chins
        disp("Batch Processing every chin, pre and post...This might take a while!")
        cd(data_dir)
        all_chins = dir(sprintf('Baseline/Q*')); 
        
        for z = 1:numel(all_chins)
            subj = all_chins(z).name; 
            cd(data_dir)
            chins_cond = dir(sprintf('*/%s/', subj));
            cond_cell = cell(size(chins_cond));
            for folder_i = 1:size(chins_cond,1)
                cond_cell(folder_i,1) = extractBetween(chins_cond(folder_i).folder,...
                    'Data\',sprintf('%s%s', filesep, subj));
            end
            
            [conds,~,ind] = unique(cond_cell);
            cd(current_dir);

            for c = 1:size(conds,1)
                condition = conds{c}; 
                suffix = [condition, filesep,subj,filesep];
                datapath = [data_dir,suffix];
                ABR_audiogram_chin;
            end
        end
        cd(current_dir)
        
    case 3 % Plot Group Data
        disp("Plotting Group Pre vs Post...")
        datapath = data_dir;
        make_abr_summary_plots; 
        cd(current_dir)
        
    case 4 % Plot Pre/Post
        disp("Plotting Single Chin Pre vs Post...")
        cd(data_dir)
        chins_cond = dir(sprintf('*/%s/Processed/*_*', subj));
        cond_cell = cell(size(chins_cond));
        for folder_i = 1:size(chins_cond,1)
            cond_cell(folder_i,1) = extractBetween(chins_cond(folder_i).folder,'ABR\Chin\',sprintf('%s%s%s%s', filesep, subj, filesep, 'Processed'));
        end
        [conds,~,ind] = unique(cond_cell);
        cd(current_dir);

        plot_preVpost_abr; 
end