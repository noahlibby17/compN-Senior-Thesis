function [allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = Sproj_analysisPipe_5_freqAnalysis(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8)

global Subj

cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmconvol'; %mtmconvol
cfg.taper        = 'hanning'; %hanning
cfg.foi          = 1:45;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*.5;
cfg.channel      = 'all';
cfg.toi          = 0:8;
%cfg.tapsmofrq = 9;
cfg.keeptrials   = 'yes'; % classifiers operate on individual trials
%cfg.keeptapers   = 'yes'; %Keeping trials AND tapers is only possible with fourier as the output

hA_hM_5         = ft_freqanalysis(cfg, hA_hM_5);
lA_hM_6         = ft_freqanalysis(cfg, lA_hM_6);
hA_lM_7         = ft_freqanalysis(cfg, hA_lM_7);
lA_lM_8         = ft_freqanalysis(cfg, lA_lM_8);

end