function [stat] = Sproj_freqstats_onICA(ica5,ica6,ica7,ica8)

Subj = [102 105 106];

load(['C:\Users\Admin\Desktop\EmotivPro_recordings\Processing' filesep num2str(Subj(3)) '_preprocessed']);


cfg              = [];
cfg.output       = 'pow';
cfg.method       = 'mtmconvol'; %mtmconvol
cfg.taper        = 'hanning'; %hanning
cfg.foi          = 7.5:12.5;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
cfg.channel      = 'all';
cfg.toi          = 0:8;
cfg.keeptrials   = 'yes'; % classifiers operate on individual trials
%cfg.keeptapers   = 'yes'; %Keeping trials AND tapers is only possible with fourier as the output

ica5_2         = ft_freqanalysis(cfg, ica5);
ica6_2         = ft_freqanalysis(cfg, ica6);
ica7_2         = ft_freqanalysis(cfg, ica7);
ica8_2         = ft_freqanalysis(cfg, ica8);


addpath(genpath(fullfile('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128', 'external', 'dmlt')))

%
cfg         = [];
cfg.method  = 'crossvalidate';

cfg.design = [
             ones(size(ica5.trialinfo,1),1);...
             ones(size(ica6.trialinfo,1),1);...
             2*ones(size(ica7.trialinfo,1),1);...
             2*ones(size(ica8.trialinfo,1),1);...
             ];
         
cfg.channel = 'all';
cfg.latency = [0 8]; %all
cfg.frequency = [1 45]; %[4 25]
cfg.avgoverchan = 'no';
cfg.avgovertime = 'no';
cfg.avgoverfreq = 'no';

cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',.2)};
stat        = ft_freqstatistics(cfg,ica5_2,ica6_2,ica7_2,ica8_2);
stat.statistic

stat.mymodel     = stat.model{1}.weights;

cfg              = [];
cfg.layout       = stat.label;
cfg.parameter    = 'mymodel';
cfg.comment      = '';
cfg.colorbar     = 'yes';
ft_topoplotTFR(cfg,stat);
end


