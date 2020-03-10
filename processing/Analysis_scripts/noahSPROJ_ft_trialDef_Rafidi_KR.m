
% Add fieldtrip and its subfolders to the path
addpath /home/mdynamics/Documents/Matlab_offcampus/fieldtrip
ft_defaults;
%% For each new participant:

%%% CHANGE EVERYTIME %%%
parnum = 5; % Choose ind. all the KRLearn files by changing number
partfolder = 5; % Choose the comp-eeg-master participant number
%%% CHANGE EVERYTIME %%%

%%%%%%%%%%%%%%%%%%%%

home = '/home/mdynamics/Desktop/noahSPROJ/';
FileLoc = ['/home/mdynamics/Desktop/noahSPROJ_participants/AllData_Rafidi_Unprocessed/' num2str(parnum) '_KRLearn/']; % change for each participant
cd(FileLoc);
FileList = dir('*.edf');
PreStimTime = 0.5;
PostStimTime = 2;
cd('/home/mdynamics/Desktop/noahSPROJ/processing/Analysis_scripts/');

for NumFile = 1:length(FileList)
    
    %% Load and read data
    
    FileName = FileList(NumFile).name;
    FullFileName = strcat(FileLoc, '/', FileName);
    dat = ft_read_data(FullFileName);
    hdr = ft_read_header(FullFileName);
    datRS = reshape(dat,size(dat,1),size(dat,2)*size(dat,3)); % Converting 3D (Channel,Samples,Epochs) matrix to 2D (Channel,Samples)
    
    
    %% Identify which numbers were used as triggers for high and low competition trials in this participant
    
    KRpres_triglist = [ ];
    KRtest_triglist = [ ];
    
    %-----------STOP HERE------------% 
    %% LOAD KRtest.mat
    %cd('/home/mdynamics/Desktop/noahSPROJ/comp-eeg-master/Experiment/');
    
    load([home 'comp-eeg-master/Experiment/' num2str(partfolder) '/KRtest.mat']);

    
    % These are just for trial def too, nothing fancy
      
      for x = 1:length(experiment) % look at each block
        cur_exp_port = experiment(x).parPort; % open parPort for this block
        cur_exp_story = experiment(x).story; % open story for this block
        for y = 1:length(cur_exp_port) % look at each cell in parPort for this block
            disp(y);
            [~, allnum_col] = find(cur_exp_port(1, :) > 1); % pull col references for cells with triggers - don't include '1' bc I used '1' as a trigger code when I shouldn't have
            allnum_col(1) = []; % deletes the prompt trigger
            for z = 1:length(allnum_col)
                KRtest_trig = cur_exp_port(1, allnum_col(z)); % high comp trig
                isthere = 0;
                for helper = 1:length(KRtest_triglist)
                    if KRtest_triglist(helper) == KRtest_trig
                        isthere = 1;
                        break;
                    end
                end
                if isthere == 0
                    KRtest_triglist(end+1) = KRtest_trig; % bin this trigger number as a KRtest trigger
                end
            end
        end
      end
      
        
    % -----------STOP HERE------------%          
    %% LOAD presentation.mat
    load([home 'comp-eeg-master/Experiment/' num2str(partfolder) '/KRpres.mat']);
      % These are just for trial def too, nothing fancy
      
      for x = 1:length(experiment) % look at each block
        cur_exp_port = experiment(x).parPort; % open parPort for this block
        cur_exp_story = experiment(x).story; % open story for this block
        for y = 1:length(cur_exp_port) % look at each cell in parPort for this block
            disp(y);
            [~, allnum_col] = find(cur_exp_port(1, :) > 1); % pull col references for cells with triggers - don't include '1' bc I used '1' as a trigger code when I shouldn't have
            allnum_col(1) = []; % deletes the prompt trigger
            for z = 1:length(allnum_col)
                KRpres_trig = cur_exp_port(1, allnum_col(z)); % high comp trig
                isthere = 0;
                for helper = 1:length(KRpres_triglist)
                    if KRpres_triglist(helper) == KRpres_trig
                        isthere = 1;
                        break;
                    end
                end
                if isthere == 0
                    KRpres_triglist(end+1) = KRpres_trig; % bin this trigger number as a KRtest trigger
                end
            end
        end
      end
      
      
      %% Identify data markers in .edf and find events of interest
      
    %cd('/home/mdynamics/Desktop/noahSPROJ/processing/Analysis_scripts/');
    
    % * I am unsure exactly how to deal with labelling trials differently
    % for the learn and train .edf files. Does it matter? Or can I put
    % those in the same bin? I feel like they need their own bins because
    % they are different tasks, even if it is the same material for
    % competition that is at play. CONCLUSION: Create a series of if
    % statements when defining trial types to determine which file is being
    % currently processed, and thus which pipeline to go down so that i can
    % mark the trials uniquely (i.e. train high = 1, train low = 2, learn
    % high = 3, learn low = 4, etc.). ERROR IN MY THINKING: I thought that
    % the study and RP blocks were saved as separate files -- they are not.
    % In that case, I don't know if I can separate them. AH WELL :P Maybe
    % this gets closer to the kind of competition drop that Rafidi was
    % looking at because it accounts for both the initial learning and the
    % final learning. That will be my justification!
    
        % THIS IS WHERE I AM CONFUSION %
    
    % Trials for Swahili/English
    KRtestStart = []; % Initialize the holding place for trigger locations in .edf data
    for trignum = 1:length(KRtest_triglist)
        newtrig = find(datRS(20, :) == KRtest_triglist(trignum));
        for s = 1:length(newtrig)
            KRtestStart(end+1) = newtrig(s);
        end
    end
    KRpresStart = []; % Initialize the holding place for trigger locations in .edf data
    for trignum = 1:length(KRpres_triglist)
        newtrig = find(datRS(20, :) == KRpres_triglist(trignum));
        for s = 1:length(newtrig)
            KRpresStart(end+1) = newtrig(s);
        end
    end
    
    %% Epoching/segmentation
    
    % Hold trials
    Trials_KRtest = [];
    Signals_KRtest = [];
    KRtest_TrlInfo = ones(1,length(KRtestStart))*8; % 8 - for later trial id
    for blk = 1:length(KRtestStart)
        Trials_KRtest{blk} = datRS(:,KRtestStart(blk)-PreStimTime*hdr.Fs:KRtestStart(blk)+PostStimTime*hdr.Fs);
        Signals_KRtest{blk} = Trials_KRtest{blk}(3:16, :);
    end
    
    
    Trials_KRpres = [];
    Signals_KRpres = [];
    KRpres_TrlInfo = ones(1,length(KRpresStart))*9; % 9 - for later trial id
    for blk = 1:length(KRpresStart)
        Trials_KRpres{blk} = datRS(:,KRpresStart(blk)-PreStimTime*hdr.Fs:KRpresStart(blk)+PostStimTime*hdr.Fs);
        Signals_KRpres{blk} = Trials_KRpres{blk}(3:16, :);
    end
    
    
    %%%%%% I FINISHED WORKING HERE - CONTINUE FROM HERE ON OUT AND MAKE
    %%%%%% SURE EVERYTHING IS IN THE RIGHT PLACE AND TRANSERS PROPERLY FOR
    %%%%%% THIS SCRIPT AND THE OTHERS LIKE IT. 
    
    
    %% Big Data
    
    BigData = [ Trials_KRpres Trials_KRtest ];
    TrlInfoVector = [ KRpres_TrlInfo KRtest_TrlInfo ];
    
    %% Timeline
    clear TimeLine

    for NumTrl = 1:length(BigData)
        TimeAux = 1/hdr.Fs:1/hdr.Fs:size(BigData{NumTrl},2)/hdr.Fs;
        TimeLine{NumTrl} = TimeAux;
    end
    
    %% Wrapping up
    data = [];
    data.fsample = hdr.Fs;
    data.label = hdr.label;
    data.trial = BigData;
    data.time = TimeLine;
    data.trialinfo = TrlInfoVector';
    cfg = [ ];
    cfg.channel = 3:16;
    cfg.demean = 'yes';
    [data] = ft_preprocessing(cfg,data);
    
    [a,b] = strtok(FileName,'.');
    matfile = fullfile('/home/mdynamics/Desktop/noahSPROJ_participants/data/Rafidi/mat', [a '.mat']);
    save(matfile,'data');
    clear data
    
end % end full loop


