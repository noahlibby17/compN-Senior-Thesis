function [allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = Sproj_analysisPipe_3_BandpassFilter(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8)

%% Bandpass filter
cfg = [ ];

%cfg.lpfilter        = 'yes';
%cfg.lpfreq          = 40;

%cfg.hpfilter        = 'yes';
%cfg.hpfreq          = 3;

%cfg.bpfilter        = 'yes';
%cfg.bpfreq          = [1 45];
%cfg.bptype          = 'but';
%cfg.bpfiltord       =  2;
%cfg.bpfiltdir       = 'twopass';
%cfg.demean          = 'yes';
%cfg.detrend         = 'yes';
cfg.reref = 'yes';
cfg.refchannel = 'all';

allData = ft_preprocessing(cfg, allData);
hA_hM_5 = ft_preprocessing(cfg, hA_hM_5);
lA_hM_6 = ft_preprocessing(cfg, lA_hM_6);
hA_lM_7 = ft_preprocessing(cfg, hA_lM_7);
lA_lM_8 = ft_preprocessing(cfg, lA_lM_8);
end