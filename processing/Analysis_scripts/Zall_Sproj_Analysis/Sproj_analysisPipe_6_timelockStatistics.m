function [stat, allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = Sproj_analysisPipe_6_timelockStatistics(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8, config_design)

%% ft_timelockstatistics

addpath(genpath(fullfile('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128', 'external', 'dmlt')))

global which_timelockStatistics

if which_timelockStatistics(1)==5
    input1 = hA_hM_5;
elseif which_timelockStatistics(1)==6
    input1 = lA_hM_6;
elseif which_timelockStatistics(1)==7
    input1 = hA_lM_7;
elseif which_timelockStatistics(1)==8
    input1 = lA_lM_8;
end

if which_timelockStatistics(2)==5
    input2 = hA_hM_5;
elseif which_timelockStatistics(2)==6
    input2 = lA_hM_6;
elseif which_timelockStatistics(2)==7
    input2 = hA_lM_7;
elseif which_timelockStatistics(2)==8
    input2 = lA_lM_8;
end

if which_timelockStatistics(3)==5
    input3 = hA_hM_5;
elseif which_timelockStatistics(3)==6
    input3 = lA_hM_6;
elseif which_timelockStatistics(3)==7
    input3 = hA_lM_7;
elseif which_timelockStatistics(3)==8
    input3 = lA_lM_8;
end

if which_timelockStatistics(4)==5
    input4 = hA_hM_5;
elseif which_timelockStatistics(4)==6
    input4 = lA_hM_6;
elseif which_timelockStatistics(4)==7
    input4 = hA_lM_7;
elseif which_timelockStatistics(4)==8
    input4 = lA_lM_8;
end




cfg = [];
cfg.method  = 'crossvalidate';

cfg.design = config_design;
%cfg.design = [
%             ones(size(input1.trial,1),1);...
%             2*ones(size(input2.trial,1),1);...
%             ];

cfg.latency = [0 8]; 
cfg.avgoverchan = 'no'; %default = no; 
cfg.avgovertime = 'no'; %no
cfg.avgoverfreq = 'no';
cfg.parameter = 'trial'; %default = trial
cfg.nfolds = 4; %default = 5
cfg.statistic = {'accuracy' 'binomial' 'contingency'};
%cfg.resample = 'true';

cfg.mva     = {dml.standardizer dml.enet('family','binomial','alpha',.2)};

global stat
stat = ft_timelockstatistics(cfg,input1,input2, input3, input4);
stat.statistic
end