Subj = [105];

statistics = cell(length(Subj),1);

analysis_order = [1 2 3 4 5 6 7];

for i = 1:length(Subj)
    
load(['C:\Users\Admin\Desktop\EmotivPro_recordings\Processing' filesep num2str(Subj(i)) '_preprocessed']);
    
%% timelockanalysis
if analysis_order(1) == 1
%%%%% timelockAnalysis %%%%%
    [allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_5_timelockAnalysis(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);
end

cfg = [];
cfg.xlim = [0.3 0.5];
cfg.colorbar = 'yes';
cfg.layout = lay;
ft_topoplotER(cfg,hA_hM_5);
ft_topoplotER(cfg,lA_hM_6);
ft_topoplotER(cfg,hA_lM_7);
ft_topoplotER(cfg,lA_lM_8);

%% timelockstatistics
if analysis_order(2) == 2
global which_timelockStatistics
which_timelockStatistics = [5 6 7 8];  % 5 6 7 8 = mem  % 5 7 6 8 = att

config_design = [
            ones(size(hA_hM_5.trial,1),1);...
            ones(size(lA_hM_6.trial,1),1);...
            2*ones(size(hA_lM_7.trial,1),1);...
            2*ones(size(lA_lM_8.trial,1),1);...
            ];

[stat, allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_6_timelockStatistics(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8, config_design);

Sproj_Weight_TopoPLots(stat)

statistics{i} = struct2cell(stat.statistic);
end

end

%avg_accuracy = [cell2mat((statistics{1,1}(1)))+cell2mat((statistics{2,1}(1)))+cell2mat((statistics{3,1}(1)))]/(length(Subj))
