%% Plot Data
freq = zeros(numel(conds),5);
thresh = zeros(numel(conds),5);

for c = 1:size(conds,1)
    condition = conds{c,1};

    suffix = [condition, filesep,subj,filesep,'Processed'];
    datadir = [data_dir, suffix];
    cd(datadir)
    
    datafiles = dir([subj,'_',condition,'_ABR_Data.mat']);
    if size(datafiles,1) > 1
        file = uigetfile('*_ABR_Data.mat'); 
        load(file)
    elseif size(datafiles,1) == 1
        load(datafiles.name)
    else
        disp("File not found") 
        break
    end
    
    freq(c,:) = abr_out.freqs;
    thresh(c,:) = abr_out.thresholds; 
    
    
end

blck = [0.25, 0.25, 0.25];
rd = [194 106 119]./255; %TTS
blu = [148 203 236]./255; %CA
yel = [220 205 125]./255; %PTS
gre = [93 168 153]./255; %GE
cols = [blck; rd; blu]; 
figure;
hold on; 
set(gcf, 'Units', 'inches', 'Position', [1, 1, 8, 6])

for i = 1:numel(conds)
    plot(freq(i,:)./1e3,thresh(i,:), '-o','Color',cols(i,:),'linewidth',4, 'MarkerSize', 8)
end

hold off;
ylim([0,100])
ylabel('Threshold (dB SPL)')
xlabel('Frequency (kHz)')
xlim([0.5, 8])
xticks([.5,1,2,4,8])
set(gca, 'FontSize', 20, 'XScale', 'log')
title('Pre vs Post', 'FontSize', 24, 'Color', rd);
grid on
cd(current_dir)