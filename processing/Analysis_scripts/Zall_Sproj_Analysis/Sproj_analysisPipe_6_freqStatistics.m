function [stat,allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = Sproj_analysisPipe_6_freqStatistics(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8, config_design)

global Subj

addpath(genpath(fullfile('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128', 'external', 'dmlt')))

global which_freqStatistics

if which_freqStatistics(1)==5
    input1 = hA_hM_5;
elseif which_freqStatistics(1)==6
    input1 = lA_hM_6;
elseif which_freqStatistics(1)==7
    input1 = hA_lM_7;
elseif which_freqStatistics(1)==8
    input1 = lA_lM_8;
end

if which_freqStatistics(2)==5
    input2 = hA_hM_5;
elseif which_freqStatistics(2)==6
    input2 = lA_hM_6;
elseif which_freqStatistics(2)==7
    input2 = hA_lM_7;
elseif which_freqStatistics(2)==8
    input2 = lA_lM_8;
end

if which_freqStatistics(3)==5
    input3 = hA_hM_5;
elseif which_freqStatistics(3)==6
    input3 = lA_hM_6;
elseif which_freqStatistics(3)==7
    input3 = hA_lM_7;
elseif which_freqStatistics(3)==8
    input3 = lA_lM_8;
end

if which_freqStatistics(4)==5
    input4 = hA_hM_5;
elseif which_freqStatistics(4)==6
    input4 = lA_hM_6;
elseif which_freqStatistics(4)==7
    input4 = hA_lM_7;
elseif which_freqStatistics(4)==8
    input4 = lA_lM_8;
end

cfg         = [];
cfg.method  = 'crossvalidate';

cfg.design = config_design;

cfg.channel = 'all';
cfg.latency = [0 8]; %all
cfg.frequency = [.5 45]; %[.5 45]
cfg.avgoverchan = 'no';
cfg.avgovertime = 'no';
cfg.avgoverfreq = 'no';
cfg.nfolds = 5;


global stat
%cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',.2)};
cfg.mva     = {dml.standardizer dml.svm};

stat        = ft_freqstatistics(cfg,input1,input2,input3,input4);
stat.statistic
end