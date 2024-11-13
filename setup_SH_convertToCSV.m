%% DPswept Analysis - Set up Files

clear;
set(0,'defaultfigurerenderer','opengl')

%% Choose Chin and Run type
subj = 'Q365';
condition = 'Old';

export = 1; % Save data? 
mode = 0;   % 0 - Process single chin,
            % 1 - Process and Plot single chin pre/post,
            % 2 - batch process all

%if processing click, put a 0 in freqs
freqs = [500,1e3,2e3,4e3,8e3];

%% Set Directories      
uname = 'samhauser';
location = 3;

if location == 1 % School
    comp = 'F:\';
elseif location == 2 % SNAPlab
    comp = 'E:\';
elseif location == 0 % Mac
    comp = '/Volumes/SNH/';
elseif location == 3
    comp = 'D:\'; 
end

directories = ['THESIS', filesep, 'Pitch_Diagnostics_Data', filesep,...
    'ABR', filesep, 'Chin', filesep];

prefix = [comp,directories];
cwd = pwd;

%% Run analysis 
switch mode
    case 0
        disp("Processing Single Chin...");
        suffix = [condition, filesep, subj, filesep];
        datapath = [prefix,suffix];
        
        convertToCSV;      
        
    case 1
        disp("Processing Single Chin Pre vs Post...")
        cd(prefix)
        chins_cond = dir(sprintf('*/%s/Raw/*-*', subj));
        cond_cell = cell(size(chins_cond));
        for folder_i = 1:size(chins_cond,1)
            cond_cell(folder_i,1) = extractBetween(chins_cond(folder_i).folder,'ABR\Chin\',sprintf('%s%s%s%s', filesep, subj, filesep, 'Raw'));
        end
        [conds,~,ind] = unique(cond_cell);
        cd(cwd);
        
        for c = 1:size(conds,1)
            condition = conds{c}; 
            suffix = [condition, filesep,subj,filesep];
            datapath = [prefix,suffix];
            ABR_audiogram_chin;
        end
        cd(cwd)
        convertToCSV; 
        
    case 2 % Process ALL data for ALL chins
        disp("Batch Processing every chin, pre and post...This might take a while!")
        cd(prefix)
        all_chins = dir(sprintf('Baseline/Q*')); 
        
        for z = 1:numel(all_chins)
            subj = all_chins(z).name; 
            cd(prefix)
            chins_cond = dir(sprintf('*/%s/Raw/*-*', subj));
            cond_cell = cell(size(chins_cond));
            for folder_i = 1:size(chins_cond,1)
                cond_cell(folder_i,1) = extractBetween(chins_cond(folder_i).folder,...
                    'ABR\Chin\',sprintf('%s%s%s%s', filesep, subj, filesep, 'Raw'));
            end
            
            [conds,~,ind] = unique(cond_cell);
            cd(cwd);

            for c = 1:size(conds,1)
                condition = conds{c}; 
                suffix = [condition, filesep,subj,filesep,'Raw'];
                datapath = [prefix,suffix];
                convertToCSV;
            end
        end
        cd(cwd)
        
end