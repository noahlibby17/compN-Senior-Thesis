%Sproj_analysis_frequency

clear all, clc;

subj = '102_2';

addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Processing
addpath C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128
ft_defaults

num_trigs = 4;
for i = 1:num_trigs
file = ['Sproj_P_' subj '_data' num2str(i+4) '.mat'];
load(file);
end

file = ['Sproj_P_' subj '_data.mat'];
load(file);

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

%% Independent Component Analysis (ICA)
cfg = [ ];
cfg.method = 'runica';

comp1 = ft_componentanalysis(cfg, preproc1);
comp2 = ft_componentanalysis(cfg, preproc2);
comp3 = ft_componentanalysis(cfg, preproc3);
comp4 = ft_componentanalysis(cfg, preproc4);

% plot the components for visual inspection
figure
cfg = [];
cfg.component = 1:20;       % specify the component(s) that should be plotted
cfg.layout      = 'easycapM25.mat';
cfg.comment   = 'no';
ft_topoplotIC(cfg, comp1)
%% timelockanalysis
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

%% ft_freqanalysis

cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmconvol'; %mtmconvol
cfg.taper        = 'hanning'; %hanning
cfg.foi          = 2:1:44;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
cfg.channel      = 'all';
cfg.toi          = 0:.5:8;
cfg.keeptrials   = 'yes'; % classifiers operate on individual trials
%cfg.keeptapers   = 'yes'; %Keeping trials AND tapers is only possible with fourier as the output

% f1         = ft_freqanalysis(cfg, preproc1);
% f2         = ft_freqanalysis(cfg, preproc2);
% f3         = ft_freqanalysis(cfg, preproc3);
% f4         = ft_freqanalysis(cfg, preproc4);

f1         = ft_freqanalysis(cfg, t1);
f2         = ft_freqanalysis(cfg, t2);
f3         = ft_freqanalysis(cfg, t3);
f4         = ft_freqanalysis(cfg, t4);
% 
%  f1         = ft_freqanalysis(cfg, comp1);
%  f2         = ft_freqanalysis(cfg, comp2);
%  f3         = ft_freqanalysis(cfg, comp3);
%  f4         = ft_freqanalysis(cfg, comp4);

%% ft_freqstatistics

cfg         = [];
cfg.layout      = 'easycapM25.mat';
cfg.method  = 'crossvalidate';

cfg.design = [
              ones(size(f1.powspctrm,1),1);...
              2*ones(size(f2.powspctrm,1),1);...
              3*ones(size(f3.powspctrm,1),1);...
              4*ones(size(f4.powspctrm,1),1)
              ];
          
 % .2673 with 1
 % .3762 with preproc1.label(2)      
 % .3564 with preproc1.label(3)
 % .3168 with preproc1.label(4)
 % .3069 with preproc1.label(5)
 % .3267 with 6
 % .297 with 7
 % .3069 with 8
 % .3069 with 9
 % .02970 with 10
 % .3465 with 11
 % .3267 with 12
 % .2970 with 13
 % .3366 with 14

%cfg.channel = {preproc1.label(1) preproc1.label(2)};
%     cfg.channel{1,1} = preproc1.label{2};
%     cfg.channel{2,1} = preproc1.label{11};
%     cfg.channel{3,1} = preproc1.label(3);
%     cfg.channel{4,1} = preproc1.label(4);
%     cfg.channel{5,1} = preproc1.label(5);
%     cfg.channel{6,1} = preproc1.label(6);
%     cfg.channel{7,1} = preproc1.label(7);
%     cfg.channel{8,1} = preproc1.label(8);
%     cfg.channel{9,1} = preproc1.label(9);
%     cfg.channel{10,1} = preproc1.label(10);
%     cfg.channel{11,1} = preproc1.label(11);
%     cfg.channel{12,1} = preproc1.label(12);
%     cfg.channel{13,1} = preproc1.label(13);
%     cfg.channel{14,1} = preproc1.label(14);


cfg.latency = [0 8]; %all
cfg.frequency = 'all'; %[4 25]
cfg.avgoverchan = 'no';
cfg.avgovertime = 'no';
cfg.avgoverfreq = 'no';

cfg.nfolds = 5; %default = 5
%cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',.2)};
%cfg.mva =  dml.one_against_one('mva', {dml.standardizer() dml.svm()});
cfg.mva =  dml.one_against_rest('mva', {dml.standardizer() dml.svm()}); 
stat        = ft_freqstatistics(cfg,f1,f2,f3,f4);
stat.statistic

%% ft_topoplotTFR

stat.mymodel     = stat.model{1}.primal;

cfg              = [];
cfg.layout      = 'easycapM25.mat';
cfg.parameter    = 'mymodel';
cfg.comment      = '';
cfg.colorbar     = 'yes';
cfg.interplimits = 'electrodes';
ft_topoplotTFR(cfg,stat);