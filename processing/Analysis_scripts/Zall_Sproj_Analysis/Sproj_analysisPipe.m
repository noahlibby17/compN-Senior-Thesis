addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Processing % add the save path
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Analysis_scripts % add the save path

Subj = 102;
%   hA_hM = 5
%   lA_hM = 6
%   hA_lM = 7
%   lA_lM = 8


%% Load in the files to matlab workspace
[allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_2_LoadIn(Subj);

%% Apply filtering
[allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_3_BandpassFilter(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);

%% Layout
global lay
Sproj_analysisPipe_4_LoadLayout %this just loads in 'lay'

save(['Processing' filesep num2str(Subj) '_preprocessed'],'allData','hA_hM_5','lA_hM_6', 'hA_lM_7', 'lA_lM_8'); 
%% ICA
% 
% ica = Sproj_ICA(5,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8,lay);
% ica = Sproj_ICA(6,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8,lay)
% ica = Sproj_ICA(7,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8,lay)
% ica = Sproj_ICA(8,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8,lay)
% 
% cfg          = [];
% cfg.viewmode = 'component';
% cfg.layout   = lay; % specify the layout file that should be used for plotting
% ft_databrowser(cfg, ica)

% cfg.path = 'C:\Users\Admin\Desktop\EmotivPro_recordings\ica_output';
% cfg.prefix = 'ica';
% cfg.layout = ica.topolabel;
% rej_comp = ft_icabrowser(cfg, ica);

%% %%%%% timelockAnalysis %%%%%
[allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_5_timelockAnalysis(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);
%% %%%%%timelockStats%%%%%
global which_timelockStatistics

%%% hA vs lA
% which_timelockStatistics = [6 8 5 7]; % hA vs lA
% config_design = [
%             ones(size(lA_hM_6.trial,1),1);...
%             ones(size(lA_lM_8.trial,1),1);...
%             2*ones(size(hA_hM_5.trial,1),1);...
%             2*ones(size(hA_lM_7.trial,1),1);...
%             ];

%% hM vs lM
which_timelockStatistics = [7 8 5 6]; 
% 5 6 7 8 = mem
% 5 7 6 8 = att


config_design = [
            ones(size(hA_lM_7.trial,1),1);...
            ones(size(lA_lM_8.trial,1),1);...
            2*ones(size(hA_hM_5.trial,1),1);...
            2*ones(size(lA_hM_6.trial,1),1);...
            ];
        
[allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_6_timelockStatistics(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8, config_design);

%% freqAnalysis        
[allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_5_freqAnalysis(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);

%% Freqplot

cfg = [];	
cfg.layout = lay;
cfg.channel = 'all'; % top figure
figure; ft_singleplotER(cfg, hA_hM_5);
figure; ft_singleplotTFR(cfg, lA_hM_6);
figure; ft_singleplotTFR(cfg, hA_lM_7);
figure; ft_singleplotER(cfg, lA_lM_8);


%% freqStatistics


% config_design = [
%             ones(size(lA_hM_6.trialinfo,2),1);...
%             ones(size(lA_lM_8.trialinfo,2),1);...
%             2*ones(size(hA_hM_5.trialinfo,2),1);...
%             2*ones(size(hA_lM_7.trialinfo,2),1);...
%             ];

config_design = [
            ones(length(lA_hM_6.trialinfo),1);...
            ones(length(lA_lM_8.trialinfo),1);...
            2*ones(length(hA_hM_5.trialinfo),1);...
            2*ones(length(hA_lM_7.trialinfo),1);...
            ];


global which_freqStatistics
which_freqStatistics = [6 8 5 7];
[allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_6_freqStatistics(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8,config_design);

%% topoPlot ER

Sproj_analysisPipe_plotStats_topoER

