function Sproj_analysisPipe_1_LoadupAndSave(x)

%%Sproj pre-analysis script
addpath C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Processing % add the save path
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Analysis_scripts % add the save path
ft_defaults

%%%%%%%%%%%%
Subj=106%%%%
%%%%%%%%%%%%

Subj_str = num2str(Subj);

file = ['C:\Users\Admin\Desktop\EmotivPro_recordings\Sproj_P_' Subj_str '.edf'];

dat = ft_read_data(file);
hdr = ft_read_header(file);

%% CAMT file stuff
CAMT_output_file = ['C:\Users\Admin\Desktop\EmotivPro_recordings\CAMT_results\resultfile_' Subj_str '.txt'];
CAMT_output = fopen(CAMT_output_file,'rt');
CAMT_output_1 = textscan(CAMT_output,'%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','HeaderLines', 1,'whitespace', '\t');
fclose(CAMT_output);

CAMT_output_images = cellstr(CAMT_output_1{1,4}); %convert image cells to strings

for i = 1:length(CAMT_output_images) % get rid of numbers in there for some reason
    if length(CAMT_output_images{i}) == 8
        CAMT_output_images{i} = [];
    end
end

% collapse across empty cells
CAMT_output_images = CAMT_output_images(~cellfun(@isempty, CAMT_output_images(:,1)), :);
        
%% recog file
recog_output_file = ['C:\Users\Admin\Desktop\EmotivPro_recordings\CAMT_results\resultfile_' Subj_str '_recog.txt'];
recog_output = fopen(recog_output_file,'rt');
recog_output_1 = textscan(recog_output,'%d %s %d %s %s %d %f %d','HeaderLines', 1,'whitespace', '\t');
fclose(recog_output);

%% correctness array in recog order
correctOrNot_recogOrder = cellstr(recog_output_1{1,4});
correctOrNot_recogOrder = correctOrNot_recogOrder(1:2:end,:); %delete NaNs

nonlure_images_recogOrder = recog_output_1{1,5};
nonlure_images_recogOrder = nonlure_images_recogOrder(1:2:end,:); %delete lures

for i = 1:length(nonlure_images_recogOrder)
    nonlure_images_recogOrder(i,2) = correctOrNot_recogOrder(i);
end
images_and_correct_recogOrder = nonlure_images_recogOrder;

%% correctness array in CAMT order
for i = 1:length(images_and_correct_recogOrder)
    index = find(strcmp([images_and_correct_recogOrder(:)],[CAMT_output_images{i,1}]));
    CAMT_output_images(i,2) = images_and_correct_recogOrder(index,2);
end

images_and_correct_CAMTorder = CAMT_output_images;
%% View events
% addpath C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128
% addpath C:\Users\Admin\Desktop\EmotivPro_recordings
% filename = '5_full_camt_woMotion.edf';
% ft_defaults
% hdr   = ft_read_header(filename, 'checkmaxfilter', 'no');
% 
% detectflank = 'both' % auto down bit peak trough default up
% trigindx = 20;       
% event = ft_read_event(filename, 'checkmaxfilter', 'no', 'header', hdr); % 'detectflank', detectflank,

%% Emotiv format fix
%%"If you're using the Emotiv neuroheadset to collect your EEG data you need
% to restructure your data, which is saved in the .edf file as a 3 dimensional
% matrix, into a 2 dimensional matrix that will be readable by Fieldtrip."
% from:<https://bitbucket.org/joelab/eeg-tutorial/wiki/Chapter%201%20-%20First%20Steps%2C%20Loading%20Data%2C%20and%20Initial%20Preprocessing?>
datRS = reshape(dat,size(dat,1),size(dat,2)*size(dat,3));

%% trigger fix

for i = 1:length(datRS(20,:))
    if datRS(20,i) > 0
    datRS(20,i) = (datRS(20,i)-48); % for some reason, the trigger values have 48 added to the number
    end
end

%% Subsequent Memory Effect trgger changes
for i = 1:length(images_and_correct_CAMTorder)
images_and_correct_CAMTorder{i,2} = str2double(images_and_correct_CAMTorder{i,2});
end

o = 1;
for i = 1:length(datRS(20,:))
    if datRS(20,i) == 1 % for each HIGHATT image
        if images_and_correct_CAMTorder{o,2} == 1 %if it was remembered
            o=o+1;
            datRS(20,i) = 5; %hA_hM
        elseif images_and_correct_CAMTorder{o,2} == 0 % if it wasn't remembered
            o=o+1;
            datRS(20,i) = 7; %hA_lM
        end    
    elseif datRS(20,i) == 2 % for each LOWATT image
        if images_and_correct_CAMTorder{o,2} == 1 %if it was remembered
            o=o+1;
            datRS(20,i) = 6; %lA_hM
        elseif images_and_correct_CAMTorder{o,2} == 0 % if it wasn't remembered
            o=o+1;
            datRS(20,i) = 8; %lA_lM
        end
    end
end
    

%% Find Trigs in data

num_trigs = 4;
hA_hM = find(datRS(20,:) == 5);
lA_hM = find(datRS(20,:) == 6);
hA_lM = find(datRS(20,:) == 7);
la_lM = find(datRS(20,:) == 8);

%% ID Epochs

% Full flips
for ii_1 = 1:length(hA_hM)
hA_hM_start(ii_1)          = {datRS(:,hA_hM(ii_1):hA_hM(ii_1)+8*hdr.Fs)}; % Identify HighAtt epochs from from start to start + 8sec*sampling rate
end
hA_hM_TrlInfo              = ones(1,length(hA_hM_start))*5;

for ii_2 = 1:length(lA_hM)
lA_hM_start(ii_2)           = {datRS(:,lA_hM(ii_2):lA_hM(ii_2)+8*hdr.Fs)}; % Identify LowAtt epochs from start to start + 8sec*sampling rate
end
lA_hM_TrlInfo               = ones(1,length(lA_hM_start))*6;

% Reflips
for ii_3 = 1:length(hA_lM)
hA_lM_start(ii_3)   = {datRS(:,hA_lM(ii_3):hA_lM(ii_3)+8*hdr.Fs)}; % Identify HighAtt reflips from start to start + 8sec*sampling rate
end
hA_lM_TrlInfo       = ones(1,length(hA_lM_start))*7;

for ii_4 = 1:length(la_lM)
lA_lM_start(ii_4)    = {datRS(:,la_lM(ii_4):la_lM(ii_4)+8*hdr.Fs)}; % Identify HighAtt reflips from start to start + 8sec*sampling rate
end
lA_lM_TrlInfo        = ones(1,length(lA_lM_start))*8;

%% List Unique epochs and their associated TRLINFO
BigData        = [hA_hM_start lA_hM_start hA_lM_start lA_lM_start];
TrlInfoVector  = [hA_hM_TrlInfo lA_hM_TrlInfo hA_lM_TrlInfo lA_lM_TrlInfo]; % HighAtt_TrlInfo]

%% Create Timeline for Epochs... Not totally sure what this is
clear TimeLine
TimeLine = [];
    for iii = 1:length(BigData) % for how many unique epochs there are
        TimeAux = 1/hdr.Fs:1/hdr.Fs:size(BigData{iii},2)/hdr.Fs;
        TimeLine{iii} = TimeAux;
    end
    
%% read it into Fieldtrip format

data.fsample = hdr.Fs;
data.label = hdr.label;
data.trial = BigData;
data.time = TimeLine;
data.trialinfo = TrlInfoVector';
cfg = [];                                   % create an empty variable called cfg
cfg.channel = 3:16;
cfg.demean = 'yes';

%% define_trial attempt
% addpath C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128
% addpath C:\Users\Admin\Desktop\EmotivPro_recordings
% ft_defaults
% 
% file = '5_full_camt_woMotion.edf';
% %hdr = ft_read_header(file);
% 
% cfg =[];
%     cfg.trialdef.eventtype  = '?';
%     cfg.trialdef.eventvalue = [1 2 3 4];
%     cfg.dataset = file;
%     cfg.trialdef.poststim   = 8;
%     cfg.headerfile = file;
% 
%     [cfg] = ft_definetrial(cfg);

%% Preprocess

%cfg.reref = 'yes'; %CHECK OUT PRE-PROCESSING LATER [Error using surf (line 75) X, Y, Z, and C cannot be complex.]
%cfg.refchannel = 'all';
[data] = ft_preprocessing(cfg,data);
load('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128\template\layout\easycapM20.mat');

%cfg = [ ];
%cfg.method = 'runica';
%data = ft_componentanalysis(cfg,data);

global lay
Sproj_analysisPipe_4_LoadLayout %this just loads in 'lay'
% plot ica
% cfg = [];
% cfg.component = 1:15; 
% cfg.layout    = lay;  
% cfg.comment   = 'no';
% figure; ft_topoplotIC(cfg, data)


%cfg          = [];
%cfg.viewmode = 'component';
%cfg.layout   = lay; % specify the layout file that should be used for plotting
%ft_databrowser(cfg, ica5)

% RUN THIS AFTER ICA AND PLOTTING
%
% reject components
%cfg.component = [1 2 3 8 14]; %%THESE WILL BE REJECTED%%
%data = ft_rejectcomponent(cfg,data);

%% Segmenting data

% Lets start with Trigger 1
data1 = [];
data1.fsample = data.fsample;
data1.trialinfo = data.trialinfo(1:ii_1,1);
data1.sampleinfo = data.sampleinfo(1:ii_1,1:2);
data1.trial = data.trial(1,1:ii_1);
data1.time = data.time(1,1:ii_1);
data1.label = data.label;
data1.cfg = data.cfg;

data2 = [];
data2.fsample = data.fsample;
data2.trialinfo = data.trialinfo((ii_1+1):(ii_1+ii_2),1);
data2.sampleinfo = data.sampleinfo((ii_1+1):(ii_1+ii_2),1:2);
data2.trial = data.trial(1,(ii_1+1):(ii_1+ii_2));
data2.time = data.time(1,(ii_1+1):(ii_1+ii_2));
data2.label = data.label;
data2.cfg = data.cfg;

data3 = [];
data3.fsample = data.fsample;
data3.trialinfo = data.trialinfo((ii_1+ii_2+1):(ii_1+ii_2+ii_3),1);
data3.sampleinfo = data.sampleinfo((ii_1+ii_2+1):(ii_1+ii_2+ii_3),1:2);
data3.trial = data.trial(1,(ii_1+ii_2+1):(ii_1+ii_2+ii_3));
data3.time = data.time(1,(ii_1+ii_2+1):(ii_1+ii_2+ii_3));
data3.label = data.label;
data3.cfg = data.cfg;

data4 = [];
data4.fsample = data.fsample;
data4.trialinfo = data.trialinfo((ii_1+ii_2+ii_3+1):(ii_1+ii_2+ii_3+ii_4),1);
data4.sampleinfo = data.sampleinfo((ii_1+ii_2+ii_3+1):(ii_1+ii_2+ii_3+ii_4),1:2);
data4.trial = data.trial(1,(ii_1+ii_2+ii_3+1):(ii_1+ii_2+ii_3+ii_4));
data4.time = data.time(1,(ii_1+ii_2+ii_3+1):(ii_1+ii_2+ii_3+ii_4));
data4.label = data.label;
data4.cfg = data.cfg;

cfg          = [];
cfg.method   = 'summary';
cfg.alim     = 1e-12; 
data1        = ft_rejectvisual(cfg,data1); 
data2        = ft_rejectvisual(cfg,data2); 
data3        = ft_rejectvisual(cfg,data3);
data4        = ft_rejectvisual(cfg,data4); 


%% Save
addpath C:\Users\Admin\Desktop\EmotivPro_recordings\Processing % add the save path

for iiii = 1:num_trigs
[filepath,filename,ext] = fileparts(file); % get the parts of the filename
matfile = fullfile('C:\Users\Admin\Desktop\EmotivPro_recordings\Processing', [filename '_data' num2str(iiii+4) '.mat']); % Location and fileextension for save

save(matfile, ['data' num2str(iiii)]); %save it
end

matfile = fullfile('C:\Users\Admin\Desktop\EmotivPro_recordings\Processing', [filename '_data.mat']); % Location and fileextension for save
save(matfile, 'data'); %save it
disp('done')
end
