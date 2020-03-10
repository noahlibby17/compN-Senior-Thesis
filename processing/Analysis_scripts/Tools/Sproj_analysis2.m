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

preproc1 = ft_redefinetrial(cfg,eval(['data' num2str(1)]));
preproc2 = ft_redefinetrial(cfg,eval(['data' num2str(2)]));
preproc3 = ft_redefinetrial(cfg,eval(['data' num2str(3)]));
preproc4 = ft_redefinetrial(cfg,eval(['data' num2str(4)]));

%% Bandpass filter
cfg = [ ];
cfg.bpfilter        = 'yes';
cfg.bpfreq          = [1 45];
cfg.bptype          = 'but';
cfg.bpfiltord       = 2;
cfg.bpfiltdir       = 'twopass';
cfg.demean          = 'yes';
cfg.detrend         = 'yes';

[preproc1] = ft_preprocessing(cfg, preproc1);
[preproc2] = ft_preprocessing(cfg, preproc2);
[preproc3] = ft_preprocessing(cfg, preproc3);
[preproc4] = ft_preprocessing(cfg, preproc4);

%% multivariate analysis

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


addpath(genpath(fullfile('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128', 'external', 'dmlt')))

cfg = [];
cfg.method  = 'crossvalidate';

cfg.design = [
              ones(size(t1.trial,1),1);...
              2*ones(size(t2.trial,1),1);...
              3*ones(size(t3.trial,1),1);...
              4*ones(size(t4.trial,1),1)
              ];
         
         
 cfg.latency = [0 8];
 cfg.statistic = {'accuracy' 'binomial' 'contingency'};
 stat = ft_timelockstatistics(cfg,t1,t2,t3,t4);
              
 
 %% topoplot
 
 stat.mymodel = stat.model{1}.primal;
 
 cfg             = [];
cfg.parameter   = 'mymodel';
cfg.xlim        = [0 1];
cfg.comments    = '';
cfg.layout      = 'easycapM25.mat';
cfg.colorbar    = 'yes';
cfg.interplimits= 'electrodes';
ft_topoplotTFR(cfg,stat);

%% Prepare layout?


%% Sensor level classification in the frequency domain

cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:2:14;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
cfg.channel      = 'all';
cfg.toi          = 0:.5:2;
cfg.keeptrials   = 'yes'; % classifiers operate on individual trials

f1         = ft_freqanalysis(cfg, preproc1);
f2         = ft_freqanalysis(cfg, preproc2);
f3         = ft_freqanalysis(cfg, preproc3);
f4         = ft_freqanalysis(cfg, preproc4);

%% crossvalidate

cfg         = [];
cfg.layout      = 'easycapM25.mat';
cfg.method  = 'crossvalidate';

cfg.design = [
              ones(size(f1.powspctrm,1),1);...
              2*ones(size(f2.powspctrm,1),1);...
              3*ones(size(f3.powspctrm,1),1);...
              4*ones(size(f4.powspctrm,1),1)
              ];
         

stat        = ft_freqstatistics(cfg,f1,f2,f3,f4);

%% Dimension reduction / feature selection

cfg         = [];
cfg.layout      = 'easycapM25.mat';
cfg.method  = 'crossvalidate';
cfg.design = [
              ones(size(f1.powspctrm,1),1);...
              2*ones(size(f2.powspctrm,1),1);...
              3*ones(size(f3.powspctrm,1),1);...
              4*ones(size(f4.powspctrm,1),1)
              ];

cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',0.2)};

stat = ft_freqstatistics(cfg,f1,f2,f3,f4);
stat.statistic

 % topoplot
 
 stat.mymodel = stat.model{1}.weights;
 
cfg             = [];
cfg.parameter   = 'mymodel';
cfg.layout      = 'easycapM25.mat';
cfg.xlim        = [0 8];
cfg.comments    = '';
cfg.colorbar    = 'yes';
cfg.interplimits= 'electrodes';
ft_topoplotER(cfg,stat);


%% Visual inspection and artifact rejection
cfg          = [ ];
cfg.method   = 'summary';
cfg.layout   = 'biosemi64.lay';

dataRej        = ft_rejectvisual(cfg,preproc1);


%% Independent Component Analysis (ICA)
cfg = [ ];
cfg.method = 'runica';

comp = ft_componentanalysis(cfg, dataRej);


%% Visual inspection of the topographical disposition of the components
figure
cfg = [ ];
cfg.component = [1:14];
cfg.layout = 'biosemi64.lay';
cfg.comment = 'no';
cfg.zlim = [-3 5]; % adjust the scale
ft_topoplotIC(cfg, comp);

%% Component inspection 1 - browse whole data 
% look for a blink in the whole dataset...remember the trial!
cfg = [ ];
cfg.channel = [1 14];
ft_databrowser(cfg,dataRej);

%% Component inspection 2 - browse individual trial & component
figure;plot(comp.trial{2}(1,:)) % plot(comp.trial{X}(Y,:)) , X= trial & Y=component

%%
%To see if the plateaus in trial 88 and 389 were truly eye movements (component 6), your code would look like this
% figure;plot(comp.trial{88}(6,:)) % plot(comp.trial{X}(Y,:)) , X= trial & Y=component 
% figure;plot(comp.trial{389}(6,:)) % plot(comp.trial{X}(Y,:)) , X= trial & Y=component 


%% Once you are sure that your components represent noise (eye movement, bad signals), it is time to eliminate them from your data.
%% Removing components
cfg = [ ];
cfg.component = [ 1 6 ];   % Components to be removed should be in between [ ]
data = ft_rejectcomponent(cfg,comp);

%% Save 'clean' data with suffix indicating component rejected version
%save([ FileName '_CompRej.mat'],'data') 