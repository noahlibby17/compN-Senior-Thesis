%% This script will epoch all segments of the newly-converted .mat file
% into 2-second epochs, perform a bandpass filter, ICA, and artifact
% rejection of visually inspected artifacts. Preprocessed data will be
% saved with the suffix '_CompRej.mat' into the same mat directory for
% further analyses. 

ft_defaults;

% Load the .mat file as a variable in Matlab workspace
FileName = '3_CompN_Train'; %write name of data file

%% Redefine each trial into epochs of 2 seconds
cfg = [ ];
cfg.length = 2.5;
cfg.minlength = 2.5;
cfg.reref = 'yes';
cfg.refchannel = 'all';
%cfg.trials = 'all';
%dataredef = ft_redefinetrial(cfg, data);

%% Bandpass filter - redefine these filters probably?
cfg = [ ];
cfg.bpfilter        = 'yes';
cfg.bpfreq          = [0.1 30]; % change this probably?
cfg.bptype          = 'but'; % check what this means
cfg.bpfiltord       = 2; % what does this mean
cfg.bpfiltdir       = 'twopass'; % what does this mean
cfg.demean          = 'yes'; % what does this mean
cfg.detrend         = 'yes'; % what does this mean

[preproc] = ft_preprocessing(cfg, data);

%% Visual inspection and artifact rejection
cfg          = [ ];
cfg.method   = 'summary';
cfg.layout   = 'emotiv16.lay';

dataRej        = ft_rejectvisual(cfg,preproc);

%% Independent Component Analysis (ICA)
%{
cfg = [ ];
cfg.method = 'runica'; % is runica what I want? What is ICA?

comp = ft_componentanalysis(cfg, dataRej);
%}

%% Topo plot
%{
figure
cfg = [ ];
cfg.component = [1:14];
cfg.layout = 'emotiv16.lay';
cfg.comment = 'no';
cfg.zlim = [-3 5]; % adjust the scale
ft_topoplotIC(cfg, comp);
%}

%% Component inspection 1 - browse whole data 
% look for a blink in the whole dataset...remember the trial!
cfg = [ ];
cfg.channel = 'all';
ft_databrowser(cfg,dataRej);


%% STOP THE SCRIPT HERE TO INPUT NEW DATA BELOW
% ------------------------------------------------------------------------%
%% Check to see if actually artifacts - change below after doing above and run only ones that you need
%{
blinks = [2 59 71 73 78 132 145 166 136];
moves = [32 97 165];
noise = [3 37 58 95 100 110 115 130 136 137 211];
components = [3 5 1]; % [blinks moves noise]

% check graphs for blinks
for i = 1:length(blinks)
    figure;plot(comp.trial{blinks(i)}(components(1),:)) 
end

% check graphs for moves
for i = 1:length(moves)
    figure;plot(comp.trial{moves(i)}(components(2),:)) 
end

% check graphs for noise
for i = 1:length(noise)
    figure;plot(comp.trial{noise(i)}(components(3),:)) 
end
%}
%% Removing components
%{
cfg = [];
% In cfg.componenent, put the numbers of the components from above that you
% want to reject after visually analyzing the problem trials in regard to those
% components
cfg.component = [3 5 1];
data = ft_rejectcomponent(cfg,comp);
%}

%% Save 'clean' data in a new location
cd('/home/mdynamics/Desktop/data/TrialRej/');
save([FileName '_TrialRej.mat'], 'data')
