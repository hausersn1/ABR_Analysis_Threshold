%Author (s): Andrew Sivaprakasam
% Modified and compiled for practice use by Samantha Hauser
%Last Updated: September 2024
%Description: Script to estimate and process ABR thresholds based on bootstrapped
%cross-corelation (loosely-based on Luke Shaheen ARO2024 presentation)

close all;

cwd = pwd;
addpath(cwd)

fs = 8e3; %resampled to 8e3
samps = 200; % how many trials it is going to take
iters = 200; % how many bootstrap iterations it will do

%% Change into directory
cd([datapath,'/Raw']);

%% Fitting Properties
x = 0:0.1:15;
maximum = .8;
mid =15;
steep = 0.05;
start = 0;
sigmoid = '(a-d)./(1+exp(-b*(x-c)))+d'; % will fit data to this equation
startPoints = [maximum, steep, mid, start];

% set upper and lower bounds of a,b,c,d as well as estimated starting
% values
fops = fitoptions('Method','NonLinearLeastSquares',...
    'Lower',[0, 0, -20, 0],'Upper',[1.5, inf, 200, 1],...
    'StartPoint',startPoints);
ft = fittype(sigmoid,'options',fops);

%% Initialize figures for plotting
abr_vis = figure();
set(abr_vis,'Position',[15 105 1200 650])

fit_vis = figure();
set(fit_vis,'Position',[25 200 809 474])

%% Load the files for a given freq
for f = 1:length(freqs)

    %find files
    if freqs(f) == 0
        datafiles = {dir(fullfile(cd,'p*click*.mat')).name}
    else
        files = dir(fullfile(cd,['p*',num2str(freqs(f)),'*.mat']));
        datafiles = {files.name};
    end

    % Initialize some variables 
    lev = [];
    wforms=[];
    cor_temp = [];
    cor_err_temp = [];
    nr_flag = false;
    
    % loop through each datafile for a given frequency (f, outer loop)
    for d = 1:length(datafiles)
        load(datafiles{d})
        fs_orig = x.Stimuli.RPsamprate_Hz;
        all_trials  = x.AD_Data.AD_All_V{1}; % get all the data (older files may be different here!)
        lev(d) = x.Stimuli.MaxdBSPLCalib-x.Stimuli.atten_dB; % get the sound level

        %2nd dimension in run levels for some reason (may be the case for
        %different iterations of NEL saving
        if iscell(all_trials)
            all_trials = all_trials{1};
        end

        %Demean and resample 
        all_trials = all_trials-mean(all_trials,'all');
        all_trials  = all_trials'./x.AD_Data.Gain;
        all_trials = resample(all_trials, fs, round(fs_orig));

        % Could add filter here [300,3e3] (match SR560 limit)
        % [b,a] = butter(4,[300,3e3]./(fs/2));
        % all_trials = filtfilt(b,a,all_trials);

        %Separate into pos/negs
        all_pos = all_trials(:,1:2:end);
        all_neg = all_trials(:,2:2:end);

        % ??? only correlate where the waves should be
        win = 1:size(all_trials,1); %20:160; % samps

        %Bootstrap - return the means of iters number of replicates (with samps number of
        %samples)
        pos_boot_1 = helper.boots(all_pos(:,1:2:end), samps, iters);
        neg_boot_1 = helper.boots(all_neg(:,1:2:end), samps, iters);
        combined_1 = (pos_boot_1 + neg_boot_1)/2;
        
        pos_boot_2 = helper.boots(all_pos(:,2:2:end), samps, iters);
        neg_boot_2 = helper.boots(all_neg(:,2:2:end), samps, iters);
        combined_2 = (pos_boot_2 + neg_boot_2)/2;

        %Cross-correlate first half w/second half
        xcor_t = helper.xcorr_matrix(combined_1(win,:),combined_2(win,:));
        
        %points at zero lag
        midpoint = ceil(size(xcor_t,1)/2);
        cor = mean(xcor_t(midpoint,:)); %maybe can use the variability here too?
        cor_err = std(xcor_t(midpoint,:));
        cor_temp(d) = cor;
        cor_err_temp(d) = cor_err;

        % Alternative ways to get peaks in xcorr: 
        %[~, midpoint] = max(xcor_t(136:146), [], 2) % could also give it
        %some wiggle
        % [pk_cor, pk_lag] = max(xcor_t, [], 1); 
        % pk_cor_temp(d) =mean(pk_cor); 
        % pk_lag_temp(d) = mean(pk_lag); 

        % Get the averaged response (waveform)
        wforms(:,d) = mean((combined_1+combined_2)/2,2); 
    end 
    
    %sort waveforms by increasing level
    [lev,I] = sort(lev); 
    wforms = wforms(:,I);
    cor_temp = cor_temp(I);
    cor_err_temp = cor_err_temp(I); 
    
    % SH: Do we need/want to normalize here? Sometimes xcor is <0
    % cor_temp = cor_temp/max(cor_temp); %normalize
    % cor_fit = fit(lev', cor_temp',ft);
    %cor_temp = pk_cor_temp(I); %(cor_temp-min(cor_temp)); 
    cor_temp = cor_temp - min(cor_temp); 

    % fit level vs correlation with sigmoid fit(ft)
    cor_fit = fit(lev', cor_temp',ft);

    %if correlation is very low across the board, no response. 
    %TODO think about how to save an NR
    if max(cor_temp)<0.3 
        nr_flag = true;
    end

    %% Determine threshold
    %Threshold estimate is the transition point of the sigmoid: 
%     thresh(f) = cor_fit.c;
%     
%     tol = 4;
%     c_y = (cor_fit.a+cor_fit.d)/2;
%     y = (c_y-cor_fit.d)*tol;
%     thresh(f) = cor_fit.c-y/cor_fit.b;

    %Find x value on sigmoid that is 25% of the way to transition point
    % tol = .10;
    % y_transit = (cor_fit.a+cor_fit.d)/2;
    % y_thresh = cor_fit.d+tol*(y_transit-cor_fit.d);

    % SH: Change to new threshold, ie, rising portion of sigmoid
    ci = confint(cor_fit); % look at a confidence interval around d (baseline of sigmoid)
    max_d = ci(2,4); 
    y_thresh= cor_fit.d + 0.1; % go a little above d? 

    %invert the equation to calculate level from place where xcor =
    %threshold amount
    thresh(f) = cor_fit.c-log((cor_fit.a-cor_fit.d)/(y_thresh-cor_fit.d)-1)/cor_fit.b;
    
    %Mark NR as 120 dB (for now, but could think of other ways to do this)
    if nr_flag
        thresh(f) = 120; 
    end
    
    %% Plot the results
    clr_no = [0,0,0,.3]; % keep alpha light if NR
    clr_yes = [0,0,0,1]; % make darker if response

    figure(abr_vis);
    subplot(ceil(length(freqs)/3),3,f);
    buff = 1.25*max(max(wforms))*(1:size(wforms,2));
    wform_plot = wforms+buff;
    
    t = (1:size(wforms,1))/fs;
    t = t*1e3; %time in ms
    
    hold on
    if sum(lev>thresh(f))~=0
        plot(t,wform_plot(:,lev>thresh(f)),'color',clr_yes,'linewidth',2);
    end
    if sum(lev<thresh(f))~=0
        plot(t,wform_plot(:,lev<=thresh(f)),'color',clr_no,'linewidth',2);
    end
    xlim([0,30])
    hold off
    yticks(mean(wform_plot));
    yticklabels(round(lev));
    ylim([min(min(wform_plot)),max(max(wform_plot))])
    ylabel('Sound Level (dB SPL)');
    title(['Frequency = ', num2str(freqs(f)), ' Hz']);
    
    figure(fit_vis);
    subplot(ceil(length(freqs)/3),3,f);
    hold on
    title(['Frequency = ', num2str(freqs(f)), ' Hz']);
    plot(1:80,cor_fit(1:80),'--k','linewidth',2);
    errorbar(lev,cor_temp,cor_err_temp,'.b','linewidth',1.5,'markersize',10);
    ylim([0,1])
    xline(thresh(f),'r','linewidth',2);
    xticks(0:10:100);
    xtickangle(90);
    xlim([0,100]);
    xlabel('Level (dB SPL)');
    hold off
    grid on
%     yline(thresh,'r--','linewidth',2);
end 

%% Plot final audiogram
figure(abr_vis)
subplot(ceil(length(freqs)/3),3,f+1);
plot(freqs,thresh,'*-k','linewidth',2);
grid on;
xticks(freqs);
set(gca,'xscale','log');
yticks(0:10:100);
ylim([0,100]);
title('ABR-Audiogram');
xlabel('Frequency (Hz)')
ylabel('Threshold (dB SPL)');
sgtitle(['ABR Waterfall |',subj,' ',condition])

%% Save fig and export data to Processed

cd(datapath);
if export
    if ~isfolder("Processed")
        mkdir("Processed")
    end
    
    cd('Processed')
    
    print(abr_vis,[subj,'_',condition,'_ABR.png'],'-dpng','-r300');
    abr_out.freqs = freqs;
    abr_out.thresholds = thresh;
    abr_out.subj = subj;
    save([subj,'_',condition,'_ABR_Data.mat'],'abr_out');
end
rmpath(cwd)
cd(cwd);