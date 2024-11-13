%% Convert to Luke Shaheen CSV

% Initialize
fs = 8e3; %resampled to 8e3

% Create the blank CSVs





for f = 1:length(freqs)

    % Change into directory
    cd([datapath,'/Raw']);

    % load that freq CSV

    csvname = strcat(subj, '_', condition, '_', num2str(freqs(f)), '.csv');

    %find files
    if freqs(f) == 0
        datafiles = {dir(fullfile(cd,'p*click*.mat')).name};
    else
        datafiles = {dir(fullfile(cd,['p*',num2str(freqs(f)),'*.mat'])).name};
    end

    t = (1:248)/fs; % seconds

    M = [0, 0, t];

    for d = 1:length(datafiles)
        load(datafiles{d})
        fs_orig = x.Stimuli.RPsamprate_Hz;
        all_trials  = x.AD_Data.AD_All_V{1};
        lev = x.Stimuli.MaxdBSPLCalib-x.Stimuli.atten_dB;

        %2nd dimension in run levels for some reason
        if iscell(all_trials)
            all_trials = all_trials{1};
        end

        %TODO Test this
        all_trials = all_trials-mean(all_trials,'all');
        all_trials  = all_trials'./x.AD_Data.Gain;
        all_trials = resample(all_trials, fs, round(fs_orig));

        %Separate into pos/negs
        all_pos = all_trials(:,1:2:end);
        all_neg = all_trials(:,2:2:end);

        level = repmat(lev, size(all_trials,2),1);
        polarity = repmat([1; -1], size(all_pos,2),1);

        M = [M; [level, polarity, all_trials']];

    end

    cd D:\THESIS\Pitch_Diagnostics_Data\ABR\Chin\chinCSV
    writematrix(M,csvname)


end

cd(cwd)