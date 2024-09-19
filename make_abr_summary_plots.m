%% Plot ABR thresholds from new analysis

cwd = pwd();

set(0,'DefaultFigureRenderer','painters')

cd([datapath, filesep, 'Baseline']);
all_chins = dir('Q*');

% Get list of chins for each exposure
cd(datapath);
cd('CA_2wksPost')
ca_chins = dir('Q*');
ca_chins = {ca_chins.name};
cd(datapath);
cd('PTS_2wksPost')
pts_chins = dir('Q*');
pts_chins = {pts_chins.name};
cd(datapath);
cd('TTS_2wksPost')
tts_chins = dir('Q*');
tts_chins = {tts_chins.name};
cd(datapath);
cd('GE_1wkPost')
ge_chins = dir('Q*');
ge_chins = {ge_chins.name};

cd(datapath)

% Initialize results/data matrices
freq = [.5, 1, 2, 4, 8]; % kHz
baseline = zeros(numel(all_chins),numel(freq));
post = zeros(numel(all_chins),numel(freq));
exp = [];

for k = 1:numel(all_chins)
    chin = all_chins(k).name;
    
    % Get Baseline data
    cd([all_chins(k).folder,filesep, chin, filesep, 'Processed'])
    cond = 'Baseline';
    load([all_chins(k).name,'_',cond,'_ABR_Data.mat']);
    freq = abr_out.freqs/1e3; %converted to kHz
    baseline(k,:) = abr_out.thresholds;
    
    cd(datapath);
    emptyFlag = 0;
    if sum(strcmp(chin, tts_chins)>0)
        cd(fullfile('TTS_2wksPost', chin, 'Processed'))
        if isempty(dir('Q*'))
            emptyFlag = 1; 
        end
        cond = 'TTS_2wksPost';
        exp{k,1} = 'TTS';
    elseif sum(strcmp(chin, pts_chins)>0)
        cd(fullfile('PTS_2wksPost', chin, 'Processed'))
        if isempty(dir('Q*'))
            emptyFlag = 1; 
        end
        cond = 'PTS_2wksPost';
        exp{k,1} = 'PTS';
    elseif sum(strcmp(chin, ca_chins)>0)
        cd(fullfile('CA_2wksPost', chin, 'Processed'))
        if isempty(dir('Q*'))
            emptyFlag = 1; 
        end
        cond = 'CA_2wksPost';
        exp{k,1} = 'CA';
    elseif sum(strcmp(chin, ge_chins)>0)
        cd(fullfile('GE_1wkPost', chin, 'Processed'))
        if isempty(dir('Q*'))
            emptyFlag = 1; 
        end
        cond = 'GE_1wkPost';
        exp{k,1} = 'GE';
    else
        exp{k,1} = 'NA';
        cond = 'Baseline';
        emptyFlag = 1;
    end
    
    %TODO handle missing pre/post data.
    if ~emptyFlag
        load([all_chins(k).name,'_',cond,'_ABR_Data.mat'])
        post(k,:) = abr_out.thresholds;
    else
        post(k,:) = nan(size(freq));
    end
    
end
cd(cwd);

%% Plot Data

blck = [0.25, 0.25, 0.25];
rd = [194 106 119]./255; %TTS
blu = [148 203 236]./255; %CA
yel = [220 205 125]./255; %PTS
gre = [93 168 153]./255; %GE

i_blck = [0.25, 0.25, .25, 75];
i_rd = [194 106 119 75]./255; %TTS
i_blu = [148 203 236 75]./255; %CA
i_yel = [220 205 125 75]./255; %PTS
i_gre = [93 168 153 57]./255; %GE

i_cols = [i_blck; i_rd; i_blu; i_yel; i_gre]; 
cols = [blck; rd; blu; yel; gre]; 
groups = {'NH', 'TTS', 'CA', 'PTS', 'GE'}; 
subp = [0 1 3 2 4]'; 

figure;
hold on; 
set(gcf, 'Units', 'inches', 'Position', [1, 1, 16, 12])

if size(all_chins,1) == 1
    plot(freq,baseline, '-o','Color',blck,'linewidth',4, 'MarkerSize', 8)
    plot(freq,baseline, '-o','Color',rd,'linewidth',4, 'MarkerSize', 8)
else
    for j = 1:numel(all_chins)
        grp = strcmp(exp{j}, groups);
        if sum(grp) > 0
            subplot(2,2,grp * subp)
            hold on;
            plot(freq,baseline(j,:), '-o','Color',i_blck(1,1:3),'linewidth',4, 'MarkerSize', 8)
            plot(freq,post(j,:), '-o','Color',grp * i_cols,'linewidth',4, 'MarkerSize', 8)
           text(9,baseline(j,5), all_chins(j).name, 'Units', 'Data', 'Color', i_blck(1,1:3))
           text(9,post(j,5), all_chins(j).name, 'Units', 'Data', 'Color',grp * i_cols)
        end
    end
end
    % TTS
    subplot(2,2,1)
    hold on;
    title('Synaptopathy');
    
    % for i = 1:tts_count
    %     plot(freq,TTS_pre(i,:),'Color',i_blck,'linewidth',3);
    %     plot(freq,TTS_post(i,:),'Color',i_rd,'linewidth',3);
    % end
%     plot(freq,mean(TTS_pre,1, 'omitNaN'),'-o','Color',blck,'linewidth',4, 'MarkerSize', 8);
%     plot(freq,mean(TTS_post,1, 'omitNaN'),'-o','Color',rd,'linewidth',4, 'MarkerSize', 8);
%     
    hold off;
    ylim([0,100])
    ylabel('Threshold (dB SPL)')
    xlabel('Frequency (kHz)')
    xlim([0.5, 8])
    xticks(freq)
    set(gca, 'FontSize', 20, 'XScale', 'log')
    title('Synaptopathy', 'FontSize', 24, 'Color', rd);
    grid on
    
    % Carbo
    subplot(2,2,3)
    hold on;
    title('IHC Dysfunction');
    % for i = 1:ca_count
    %     plot(freq,CA_pre(i,:),'Color',i_blck,'linewidth',3);
    %     plot(freq,CA_post(i,:),'Color',i_blu,'linewidth',3);
    % end
%     plot(freq,mean(CA_pre,1, 'omitNaN'),'-o','Color',blck,'linewidth',4, 'MarkerSize', 8);
%     plot(freq,mean(CA_post,1, 'omitNaN'),'-o','Color',blu,'linewidth',4, 'MarkerSize', 8);
%     
    hold off;
    ylim([0,100])
    ylabel('Threshold (dB SPL)')
    xlabel('Frequency (kHz)')
    xlim([0.5, 8])
    xticks(freq)
    set(gca, 'FontSize', 20, 'XScale', 'log')
    title('IHC Dysfunction', 'FontSize', 24, 'Color', blu);
    grid on
    
    % PTS
    subplot(2,2,2)
    hold on;
    % for i = 1:pts_count
    %     plot(freq,PTS_pre(i,:),'Color',i_blck,'linewidth',3);
    %     plot(freq,PTS_post(i,:),'Color',i_yel,'linewidth',3);
    % end
%     plot(freq,mean(PTS_pre,1, 'omitNaN'),'-o','Color',blck,'linewidth',4, 'MarkerSize', 8);
%     plot(freq,mean(PTS_post,1, 'omitNaN'),'-o','Color',yel,'linewidth',4, 'MarkerSize', 8);
%     
    hold off;
    ylim([0,100])
    ylabel('Threshold (dB SPL)')
    xlabel('Frequency (kHz)')
    xlim([0.5, 8])
    xticks(freq)
    set(gca, 'FontSize', 20, 'XScale', 'log')
    title('Complex SNHL', 'FontSize', 24, 'Color', yel);
    grid on;
    
    subplot(2,2,4)
    hold on;
%     for i = 1:tts_count
%         plot([0,.5], [mean(TTS_pre(i,:)), mean(TTS_post(i,:))], 'o-', 'Color', rd, 'linew',4, 'MarkerSize', 8)
%     end
%     for i = 1:ca_count
%         plot([1.5,2], [mean(CA_pre(i,:)), mean(CA_post(i,:))], 'o-', 'Color', blu, 'linew',4, 'MarkerSize', 8)
%     end
%     for i = 1:pts_count
%         plot([3,3.5], [mean(PTS_pre(i,:)), mean(PTS_post(i,:))], 'o-', 'Color', yel, 'linew',4, 'MarkerSize', 8)
%     end
    ylim([0,100])
    ylabel('Threshold (dB SPL)')
    xlabel('Frequency (kHz)')
    xlim([0.5, 8])
    xticks(freq)
    set(gca, 'FontSize', 20, 'XScale', 'log')
    title('Gentamicin', 'FontSize', 24, 'Color', gre);
    grid on;
    
%% Mean Plots

CA_inds = find(strcmp(exp,'CA'));
CA_inds = CA_inds([1:5,7:end]);
ca_mean = [mean(baseline(CA_inds,:),1,"omitmissing")',mean(post(CA_inds,:),1,"omitmissing")']; %col1 pre col2 post
ca_std= [std(baseline(CA_inds,:),[],1,"omitmissing")',std(post(CA_inds,:),[],1,"omitmissing")']./sqrt(numel(CA_inds));

TTS_inds = find(strcmp(exp,'TTS'));
tts_mean = [mean(baseline(TTS_inds,:),1,"omitmissing")',mean(post(TTS_inds,:),1,"omitmissing")']; 
tts_std= [std(baseline(TTS_inds,:),[],1,"omitmissing")',std(post(TTS_inds,:),[],1,"omitmissing")']./sqrt(numel(TTS_inds));

PTS_inds = find(strcmp(exp,'PTS'));
% PTS_hi_inds = PTS_inds([2,5,6]); 
% pts_hi_mean = [mean(baseline(PTS_hi_inds,:),1,"omitmissing")',mean(post(PTS_hi_inds,:),1,"omitmissing")']; 
% pts_hi_std= [std(baseline(PTS_hi_inds,:),[],1,"omitmissing")',std(post(PTS_hi_inds,:),[],1,"omitmissing")']./sqrt(numel(PTS_hi_inds));
% 
% PTS_inds = PTS_inds([1,3,4]); 
pts_mean = [mean(baseline(PTS_inds,:),1,"omitmissing")',mean(post(PTS_inds,:),1,"omitmissing")']; 
pts_std= [std(baseline(PTS_inds,:),[],1,"omitmissing")',std(post(PTS_inds,:),[],1,"omitmissing")']./sqrt(numel(PTS_inds));

GE_inds = find(strcmp(exp,'GE'));
ge_mean = [mean(baseline(GE_inds,:),1,"omitmissing")',mean(post(GE_inds,:),1,"omitmissing")']; 
ge_std= [std(baseline(GE_inds,:),[],1,"omitmissing")',std(post(GE_inds,:),[],1,"omitmissing")']./sqrt(numel(GE_inds));

ms = 5; 
lw = 1.5; 

figure;
hold on; 
set(gcf, 'Units', 'inches', 'Position', [1, 1, 7, 2], 'Resize', 'off')

subplot(1,4,1); %'Position',[0.1370 0.2 0.1475 0.65] );
hold on
errorbar(freq,tts_mean(:,1),tts_std(:,1),'o-','color',blck,'LineWidth',lw, 'MarkerSize', ms)
errorbar(freq,tts_mean(:,2),tts_std(:,2),'o-','color',rd,'LineWidth',lw, 'MarkerSize', ms)
hold off
xticks(freq);
yticks(0:20:100);
ylim([0,100]);
%xlabel('Frequency (kHz)');
ylabel('Threshold (dB SPL)');
xlim([.4,10]);
set(gca,'XScale','log');
text(.5, 90, 'TTS','color',rd, 'FontWeight', 'bold', 'FontSize', 12)
set(gca, 'FontSize', 9)
grid on


subplot(1,4,2); %, 'Position', [0.3432 0.2 0.1475 0.65]);
hold on
errorbar(freq,ca_mean(:,1),ca_std(:,1),'o-','color',blck,'LineWidth',lw, 'MarkerSize', ms)
errorbar(freq,ca_mean(:,2),ca_std(:,2),'o-','color',blu,'LineWidth',lw, 'MarkerSize', ms)
plot(freq, post(13,:), 'x:', 'color', blu, 'LineWidth', lw, 'MarkerSize', ms+4)
plot(freq, baseline(13,:), 'x:', 'color', blck, 'LineWidth', lw, 'MarkerSize', ms+4)
hold off
xticks(freq);
yticks(0:20:100);
%xlabel('Frequency (kHz)', 'Units', 'inches', 'Position', [1, -.24, -1], 'HorizontalAlignment','center');
%set(gca, 'XLabel', 'Position', )
%ylabel('Threshold (dB SPL)');
xlim([.4,10]);
ylim([0,100]);
set(gca,'XScale','log');
text(.5, 90, 'CA','color',blu, 'FontWeight', 'bold', 'FontSize', 12)
set(gca, 'FontSize', 9)
grid on

subplot(1,4,3) %, 'Position', [0.5493 0.2 0.1475 0.65]);
hold on
errorbar(freq,pts_mean(:,1),pts_std(:,1),'o-','color',blck,'LineWidth',lw, 'MarkerSize', ms)
errorbar(freq,pts_mean(:,2),pts_std(:,2),'o-','color',yel,'LineWidth',lw, 'MarkerSize', ms)
% errorbar(freq,pts_hi_mean(:,1),pts_hi_std(:,1),'o-','color',blck,'LineWidth',lw, 'MarkerSize', ms)
% errorbar(freq,pts_hi_mean(:,2),pts_hi_std(:,2),'o-','color',yel,'LineWidth',lw, 'MarkerSize', ms)
hold off
xticks(freq);
yticks(0:20:100);
ylim([0,100]);
%xlabel('Frequency (kHz)');
%ylabel('Threshold (dB SPL)');
xlim([.4,10]);
set(gca,'XScale','log');
text(.5,90, 'PTS','color',yel, 'FontWeight', 'bold', 'FontSize', 12)
set(gca, 'FontSize', 9)
grid on

subplot(1,4,4) %, 'Position', [0.7554 0.2 0.1475 0.65]);
hold on
errorbar(freq,ge_mean(:,1),ge_std(:,1),'o-','color',blck,'LineWidth',lw, 'MarkerSize', ms)
errorbar(freq,ge_mean(:,2),ge_std(:,2),'o-','color',gre,'LineWidth',lw,'MarkerSize', ms)
hold off
xticks(freq);
yticks(0:20:100);
ylim([0,100]);
%xlabel('Frequency (kHz)');
%ylabel('Threshold (dB SPL)');
xlim([.4,10]);
set(gca,'XScale','log');
text(.5, 90,'GE','color',gre, 'FontWeight', 'bold', 'FontSize', 12)
set(gca, 'FontSize', 9)
grid on

sgtitle('Audiogram', 'FontSize', 11, 'FontWeight', 'bold')
%set(gcf,'Position',[675 240 1012 725])

