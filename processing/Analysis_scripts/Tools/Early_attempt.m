clear all, clc;
ft_defaults

addpath 'C:\Users\Admin\Desktop\EmotivPro_recordings\Processing'
file = '5_full_camt_woMotion';
load(file);

cfg = [];
cfg.length = 7;
cfg.minlength = 6;
dataredef = ft_redefinetrial(cfg,data);


%% Bandpass filter
cfg = [ ];
cfg.bpfilter        = 'yes';
cfg.bpfreq          = [1 45];
cfg.bptype          = 'but';
cfg.bpfiltord       = 2;
cfg.bpfiltdir       = 'twopass';
cfg.demean          = 'yes';
cfg.detrend         = 'yes';

[preproc] = ft_preprocessing(cfg, dataredef);

%% Visual inspection and artifact rejection
cfg          = [ ];
cfg.method   = 'summary';
cfg.layout   = 'biosemi64.lay';

dataRej        = ft_rejectvisual(cfg,preproc);


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