Subj = [106];

addpath C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128
ft_defaults
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Analysis_scripts % add the save path
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Analysis_scripts\Batch % add the save path
statistics = cell(length(Subj),1); %initialize statistics summary
group_stat = cell(length(Subj),1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analysis_order = 'frequency'; %voltage or frequency
plot = 'topo'; %'topo' or 'basic'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:length(Subj)
    
load(['C:\Users\Admin\Desktop\EmotivPro_recordings\Processing' filesep num2str(Subj(i)) '_preprocessed']);
    
if strcmp(analysis_order,'frequency')
%% freqanalysis
    [allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_5_freqAnalysis(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);

if strcmp(plot,'basic')
cfg = [];cfg.layout = lay;cfg.zlim = [0 45];cfg.channel = 'all'; cfg.maskstyle = 'opacity';

figure; ft_singleplotTFR(cfg,hA_hM_5);
figure; ft_singleplotTFR(cfg,lA_hM_6);
figure; ft_singleplotTFR(cfg,hA_lM_7);
figure; ft_singleplotTFR(cfg,lA_lM_8);
end

if strcmp(plot,'topo')
cfg = []; cfg.colorbar = 'yes'; cfg.layout = lay;
ft_topoplotTFR(cfg,hA_hM_5);
ft_topoplotTFR(cfg,lA_hM_6);
ft_topoplotTFR(cfg,hA_lM_7);
ft_topoplotTFR(cfg,lA_lM_8);
end

%% FREQstatistics
global which_freqStatistics 
which_freqStatistics = [6 5 8 7];  % 5 6 7 8 = mem  % 5 7 6 8 = att

config_design = [
            ones(length(hA_hM_5.trialinfo),1);...
            ones(length(lA_hM_6.trialinfo),1);...
            2*ones(length(hA_lM_7.trialinfo),1);...
            2*ones(length(lA_lM_8.trialinfo),1);...
            ];
        
[stat,allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_6_freqStatistics(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8, config_design);


statistics{i} = struct2cell(stat.statistic); %put batch stats into one variable
end

if strcmp(analysis_order,'voltage')
    
%% timelockanalysis
    [allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_5_timelockAnalysis(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);
if strcmp(plot,'basic')
cfg = [];
grandTime = ft_timelockgrandaverage(cfg,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);
cfg = [];cfg.channel = 'all';cfg.layout = lay;cfg.xlim = [0 1];
figure; ft_multiplotER(cfg, hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);
end

if strcmp(plot,'topo')
cfg = [];cfg.xlim = [0.3 0.5];cfg.colorbar = 'yes';cfg.layout = lay;
ft_topoplotER(cfg,hA_hM_5);
ft_topoplotER(cfg,lA_hM_6);
ft_topoplotER(cfg,hA_lM_7);
ft_topoplotER(cfg,lA_lM_8);
end

%% timelockstatistics
global which_timelockStatistics
which_timelockStatistics = [5 6 7 8];  % 5 6 7 8 = mem  % 5 7 6 8 = att

config_design = [
            ones(size(hA_hM_5.trialinfo,1),1);...
            ones(size(lA_hM_6.trialinfo,1),1);...
            2*ones(size(hA_lM_7.trialinfo,1),1);...
            2*ones(size(lA_lM_8.trialinfo,1),1);...
            ];

[stat, allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_6_timelockStatistics(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8, config_design);

%Sproj_Weight_TopoPLots(stat)

statistics{i} = struct2cell(stat.statistic);
end
%Sproj_Weight_TopoPLots(stat) %individual weight plots
group_stat{i} = stat;
end

%Sproj_Weight_TopoPLots(group_stat) %group weight plot

avg_accuracy = zeros(length(statistics),1);
for ii = 1:length(statistics)
avg_accuracy(ii) = (cell2mat((statistics{ii,1}(1))));
if cell2mat((statistics{ii,1}(2)))<.1
    disp('significant?')
    if cell2mat((statistics{ii,1}(2)))<.05
        disp('SIGNIFICANT')
    end
elseif cell2mat((statistics{ii,1}(2)))>.1
    disp('no significance')
end
end
avgavg_accuracy = mean(avg_accuracy);