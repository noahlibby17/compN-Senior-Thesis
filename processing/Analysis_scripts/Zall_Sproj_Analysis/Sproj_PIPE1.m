addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Processing % add the save path
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Analysis_scripts % add the save path

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Subj = 106; %%%%% CHANGE THIS EVERY TIME %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load in the files to matlab workspace
[allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_2_LoadIn(Subj);

%% Apply filtering
[allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8] = ...
    Sproj_analysisPipe_3_BandpassFilter(allData,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8);

%% Layout
lay = Sproj_analysisPipe_4_LoadLayout; %this just loads in 'lay'

%% run ica1
% cfg = [ ];
% cfg.method = 'runica';
% ica5 = ft_componentanalysis(cfg,hA_hM_5);

%plot ica
% cfg = [];
% cfg.component = 1:14; 
% cfg.layout    = lay;  
% cfg.comment   = 'no';
% figure; ft_topoplotIC(cfg, ica5)

%cfg          = [];
%cfg.viewmode = 'component';
%cfg.layout   = lay; % specify the layout file that should be used for plotting
%ft_databrowser(cfg, ica5)

% RUN THIS AFTER ICA AND PLOTTING
%
% reject components
% cfg.component = [1 5 6 7 11]; %%THESE WILL BE REJECTED%%
% hA_hM_5 = ft_rejectcomponent(cfg,ica5);


%% run ica2
% cfg = [ ];
% cfg.method = 'runica';
% ica6 = ft_componentanalysis(cfg,lA_hM_6);
% % 
% % plot ica
% cfg = [];
% cfg.component = 1:14; 
% cfg.layout    = lay;  
% cfg.comment   = 'no';
% figure; ft_topoplotIC(cfg, ica6)
% 
% % RUN THIS AFTER ICA AND PLOTTING
% %
% % reject components
% cfg.component = [1 2 6 8 5 9]; %% THESE WILL BE REJECTED %%
% lA_hM_6 = ft_rejectcomponent(cfg,ica6);

%% run ica3
% cfg = [ ];
% cfg.method = 'runica';
% ica7 = ft_componentanalysis(cfg,hA_lM_7);

% % plot ica
% cfg = [];
% cfg.component = 1:14; 
% cfg.layout    = lay;  
% cfg.comment   = 'no';
% figure; ft_topoplotIC(cfg, ica7)
% 
% % RUN THIS AFTER ICA AND PLOTTING
% %
% % reject components
% cfg.component = [1 4 6 9 10 11]; %% THESE WILL BE REJECTED %%
% hA_lM_7 = ft_rejectcomponent(cfg,ica7);

%% run ica4
% cfg = [ ];
% cfg.method = 'runica';
% ica8 = ft_componentanalysis(cfg,lA_lM_8);
% % plot ica
% cfg = [];
% cfg.component = 1:14; 
% cfg.layout    = lay;  
% cfg.comment   = 'no';
% figure; ft_topoplotIC(cfg, ica8)
% 
% % RUN THIS AFTER ICA AND PLOTTING
% %
% % reject components
% cfg.component = [1 2 4 6 11]; %% THESE WILL BE REJECTED %%
% lA_lM_8 = ft_rejectcomponent(cfg,ica8);

%% SAVE IT ALL
save(['C:\Users\Admin\Desktop\EmotivPro_recordings\Processing' filesep num2str(Subj) '_preprocessed'],'allData','hA_hM_5','lA_hM_6','hA_lM_7','lA_lM_8', 'lay'); 