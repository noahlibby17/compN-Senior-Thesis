function [allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = Sproj_analysisPipe_5_timelockAnalysis(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8)

%% ft_timelockanalysis

cfg                    = [];
cfg.parameter          = 'trial';
cfg.keeptrials         = 'yes'; %classifiers operate on individual trials
cfg.channel            = 'all';
cfg.vartrllength       = 0;
cfg.covariancewindow   = 'all';
cfg.covariance         = 'no';
cfg.trials             = 'all';

allData = ft_timelockanalysis(cfg, allData);
hA_hM_5 = ft_timelockanalysis(cfg, hA_hM_5);
lA_hM_6 = ft_timelockanalysis(cfg, lA_hM_6);
hA_lM_7 = ft_timelockanalysis(cfg, hA_lM_7);
lA_lM_8 = ft_timelockanalysis(cfg, lA_lM_8);

% cfg = [];
% 
% grandTime = ft_timelockgrandaverage(cfg,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);
% 
% cfg = [];
% cfg.channel = 'all';
% cfg.layout = lay;
% cfg.xlim = [0 1];
% figure; ft_multiplotER(cfg, hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);

end