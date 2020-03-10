%Sproj_analysis_time

clear all, clc;


addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Processing
addpath C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128
ft_defaults


num_trigs = 4;
for i = 1:num_trigs
file = ['Sproj_P_102_2_data' num2str(i+4) '.mat'];
load(file);
end

cfg = [];
cfg.length = 8;
cfg.minlength = 8;

data1 = ft_redefinetrial(cfg,eval(['data' num2str(1)]));
data2 = ft_redefinetrial(cfg,eval(['data' num2str(2)]));
data3 = ft_redefinetrial(cfg,eval(['data' num2str(3)]));
data4 = ft_redefinetrial(cfg,eval(['data' num2str(4)]));

%% Bandpass filter
cfg = [ ];
cfg.bpfilter        = 'yes';
cfg.bpfreq          = [1 45];
cfg.bptype          = 'but';
cfg.bpfiltord       = 2;
cfg.bpfiltdir       = 'twopass';
cfg.demean          = 'yes';
cfg.detrend         = 'yes';

[preproc1] = ft_preprocessing(cfg, data1);
[preproc2] = ft_preprocessing(cfg, data2);
[preproc3] = ft_preprocessing(cfg, data3);
[preproc4] = ft_preprocessing(cfg, data4);

%% ft_timelockanalysis

cfg                    = [];
cfg.parameter          = 'trial';
cfg.keeptrials         = 'yes'; %classifiers operate on individual trials
cfg.channel            = 'all';
cfg.vartrllength       = 0;
cfg.covariancewindow   = 'all';
cfg.covariance         = 'no';
cfg.trials             = 'all';
t1 = ft_timelockanalysis(cfg, preproc1);
t2 = ft_timelockanalysis(cfg, preproc2);
t3 = ft_timelockanalysis(cfg, preproc3);
t4 = ft_timelockanalysis(cfg, preproc4);

%% ft_timelockstatistics
addpath(genpath(fullfile('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128', 'external', 'dmlt')))

cfg = [];
cfg.method  = 'crossvalidate';

cfg.design = [
              ones(size(t1.trial,1),1);...
              2*ones(size(t2.trial,1),1);...
              3*ones(size(t3.trial,1),1);...
              4*ones(size(t4.trial,1),1)
              ];
         
 cfg.latency = [0 8]; %all
cfg.frequency = 'all'; %[4 25]
cfg.avgoverchan = 'no';
cfg.avgovertime = 'no';
cfg.avgoverfreq = 'no';

cfg.nfolds = 5; %default = 5
cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',.2)};
 cfg.statistic = {'accuracy' 'binomial' 'contingency'};
 stat = ft_timelockstatistics(cfg,t1,t2,t3,t4);
 
 %% ft_topoplotER
 
 cfg             = [];
cfg.parameter   = 'mymodel';
cfg.layout      = 'easycapM25.mat';
cfg.xlim        = [0 8];
cfg.comments    = '';
cfg.colorbar    = 'yes';
cfg.interplimits= 'electrodes';
ft_topoplotER(cfg,stat);