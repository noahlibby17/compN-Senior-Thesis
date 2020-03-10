function [allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = Sproj_analysisPipe_2_LoadIn(x)

% This loads in the data from Sproj_analysis
addpath C:\Users\Admin\Desktop\EmotivPro_recordings
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Processing
addpath C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128
ft_defaults


Subj=x;
Subj=num2str(Subj);

file = ['Sproj_P_' Subj '_data.mat'];
load(file);
file = ['Sproj_P_' Subj '_data' num2str(5) '.mat'];
load(file);
file = ['Sproj_P_' Subj '_data' num2str(6) '.mat'];
load(file);
file = ['Sproj_P_' Subj '_data' num2str(7) '.mat'];
load(file);
file = ['Sproj_P_' Subj '_data' num2str(8) '.mat'];
load(file);

cfg = [];
cfg.length = 8;
cfg.minlength = 8;

allData = ft_redefinetrial(cfg,eval('data'));
hA_hM_5 = ft_redefinetrial(cfg,eval(['data' num2str(1)]));
lA_hM_6 = ft_redefinetrial(cfg,eval(['data' num2str(2)]));
hA_lM_7 = ft_redefinetrial(cfg,eval(['data' num2str(3)]));
lA_lM_8 = ft_redefinetrial(cfg,eval(['data' num2str(4)]));
end
