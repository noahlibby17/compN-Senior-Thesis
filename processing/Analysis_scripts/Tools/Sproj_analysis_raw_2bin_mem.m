%Sproj_analysis_raw

clear all, clc;

addpath C:\Users\Admin\Desktop\EmotivPro_recordings
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Processing
addpath C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128
ft_defaults


file = ['Sproj_P_102_2_data' num2str(5) '.mat'];
load(file);
file = ['Sproj_P_102_2_data' num2str(7) '.mat'];
load(file);

cfg = [];
cfg.length = 8;
cfg.minlength = 8;

data5 = ft_redefinetrial(cfg,eval(['data' num2str(1)]));
data7 = ft_redefinetrial(cfg,eval(['data' num2str(3)]));

%% Bandpass filter
cfg = [ ];
cfg.bpfilter        = 'yes';
cfg.bpfreq          = [1 45];
cfg.bptype          = 'but';
cfg.bpfiltord       = 2;
cfg.bpfiltdir       = 'twopass';
cfg.demean          = 'yes';
cfg.detrend         = 'yes';

data5_p = ft_preprocessing(cfg, data5);
data7_p = ft_preprocessing(cfg, data7);

%% layout
load('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128\template\layout\easycapM20.mat')

%% ft_timelockanalysis

cfg                    = [];
cfg.parameter          = 'trial';
cfg.keeptrials         = 'yes'; %classifiers operate on individual trials
cfg.channel            = 'all';
cfg.vartrllength       = 0;
cfg.covariancewindow   = 'all';
cfg.covariance         = 'no';
cfg.trials             = 'all';
data5_t = ft_timelockanalysis(cfg, data5);
data7_t = ft_timelockanalysis(cfg, data7);

%% ICA

cfg = [ ];
cfg.method = 'runica';

data5_ica = ft_componentanalysis(cfg, data5_p);
data7_ica = ft_componentanalysis(cfg, data7_p);

% plot the components for visual inspection
figure
cfg = [];
cfg.component = 1:20;       % specify the component(s) that should be plotted
cfg.layout      = lay;
cfg.comment   = 'no';
ft_topoplotIC(cfg, data5_ica)

%% ft_timelockstatistics
addpath(genpath(fullfile('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128', 'external', 'dmlt')))

cfg = [];
cfg.method  = 'crossvalidate';

cfg.design = [
             ones(size(data5_t.trial,1),1);...
             2*ones(size(data7_t.trial,1),1);...
             ];

cfg.latency = [0 8]; 
cfg.frequency = 'all'; %[4 25]
cfg.avgoverchan = 'no'; %default = no; BUT MUCH HIGH ACCURACY WITH YES; messes up plotting though
cfg.avgovertime = 'no'; %no
cfg.avgoverfreq = 'no';
cfg.parameter = 'trial'; %default = trail

cfg.nfolds = 5; %default = 5
cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',.2)};
 cfg.statistic = {'accuracy' 'binomial' 'contingency'};
Att_stat = ft_timelockstatistics(cfg,data5_t,data7_t);
Att_stat.statistic

%% ft_topoplotER
Att_stat.mymodel = Att_stat.model{1}.weights;

cfg              = [];

cfg.parameter   = 'mymodel';
cfg.layout      = lay;
cfg.comment      = '';
cfg.colorbar     = 'yes';
cfg.interplimits = 'head';
ft_topoplotTFR(cfg,Att_stat);