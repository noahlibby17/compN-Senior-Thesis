%Sproj_analysis_frequency

clear all, clc;


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

data1 = ft_redefinetrial(cfg,eval(['data' num2str(1)]));
data3 = ft_redefinetrial(cfg,eval(['data' num2str(3)]));

%% Bandpass filter
cfg = [ ];
cfg.bpfilter        = 'yes';
cfg.bpfreq          = [1 45];
cfg.bptype          = 'but';
cfg.bpfiltord       = 2;
cfg.bpfiltdir       = 'twopass';
cfg.demean          = 'yes';
cfg.detrend         = 'yes';

data5_p = ft_preprocessing(cfg, data1);
data7_p = ft_preprocessing(cfg, data3);

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

data5_f         = ft_freqanalysis(cfg, data5_p);
data7_f         = ft_freqanalysis(cfg, data7_p);


%% ft_freqstatistics

cfg         = [];
cfg.layout      = 'easycapM25.mat';
cfg.method  = 'crossvalidate';

cfg.design = [
              ones(size(data5_f.powspctrm,1),1);...
              2*ones(size(data7_f.powspctrm,1),1);...
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

 cfg.channel = 'all';
%cfg.channel = {preproc1.label(1) preproc1.label(2)};
     cfg.channel{1,1} = data5_p.label{2};
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

addpath(genpath(fullfile('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128', 'external', 'dmlt')));

cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',.2)};
Att_stat        = ft_freqstatistics(cfg,data5_f,data7_f);
%Mem_stat        = ft_freqstatistics(cfg,f2,f4);
Att_stat.statistic

%% ft_topoplotTFR

stat.mymodel     = Att_stat.model{1}.weights;

cfg              = [];
cfg.layout      = 'easycapM25.mat';
cfg.parameter    = 'mymodel';
cfg.comment      = '';
cfg.colorbar     = 'yes';
cfg.interplimits = 'electrodes';
ft_topoplotTFR(cfg,stat);