function [stat] = Sproj_timelockstats_onICA(ica5,ica6,ica7,ica8)

Subj = [102 105 106];

load(['C:\Users\Admin\Desktop\EmotivPro_recordings\Processing' filesep num2str(Subj(3)) '_preprocessed']);

cfg                    = [];
cfg.parameter          = 'trial';
cfg.keeptrials         = 'yes'; %classifiers operate on individual trials
cfg.channel            = 'all';
cfg.vartrllength       = 0;
cfg.covariancewindow   = 'all';
cfg.covariance         = 'no';
cfg.trials             = 'all';

ica5_2 = ft_timelockanalysis(cfg, ica5);
ica6_2 = ft_timelockanalysis(cfg, ica6);
ica7_2 = ft_timelockanalysis(cfg, ica7);
ica8_2 = ft_timelockanalysis(cfg, ica8);

%
addpath(genpath(fullfile('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128', 'external', 'dmlt')))

cfg = [];
cfg.method  = 'crossvalidate';

cfg.design = [
             ones(size(ica5_2.trialinfo,1),1);...
             ones(size(ica6_2.trialinfo,1),1);...
             2*ones(size(ica7_2.trialinfo,1),1);...
             2*ones(size(ica8_2.trialinfo,1),1);...
             ];

cfg.latency = [.5 2]; 
cfg.avgoverchan = 'no'; %default = no; BUT MUCH HIGH ACCURACY WITH YES; messes up plotting though
cfg.avgovertime = 'no'; %no
cfg.avgoverfreq = 'no';
cfg.parameter = 'trial'; %default = trial
cfg.nfolds = 5; %default = 5
cfg.statistic = {'accuracy' 'binomial' 'contingency'};
%cfg.resample = 'true';

cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',.2)};

stat = ft_timelockstatistics(cfg,ica5_2,ica6_2, ica7_2, ica8_2);
stat.statistic

%%%%%%%%%%%%%%%

cfg = [];
cfg.layout                    = lay;
cfg.alpha                     = 0.05;
cfg.highlightseries           = {'on', 'on', 'on', 'on', 'on'}; %'on', 'labels' or 'numbers'
cfg.highlightsymbolseries     = ['**', '*', '+', 'o', '.'];
cfg.highlightsizeseries       = [6 6 6 6 6];
cfg.highlightcolorpos         = [1 0 0];
cfg.highlightcolorneg         = [0 0 1];
cfg.subplotsize               = [3 5]; %[3 5] = default
stat.mymodel = stat.model.weights;
cfg.parameter = 'mymodel';
ft_clusterplot(cfg, stat)

end