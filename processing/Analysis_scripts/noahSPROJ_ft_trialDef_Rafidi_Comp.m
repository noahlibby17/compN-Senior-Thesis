
% Add fieldtrip and its subfolders to the path
addpath /home/mdynamics/Documents/Matlab_offcampus/fieldtrip
ft_defaults;
%% For each new participant:
% Load competition.mat and presentation.mat one at
% time below
% Change FileLoc to the correct participant's folder in 'AllData_Rafidi_Unprocessed'


%%% CHANGE EVERYTIME %%%
parnum = 5; % Choose ind. all the CompTrain files by changing number
partfolder = 5; % Choose the comp-eeg-master participant number
%%% CHANGE EVERYTIME %%%

%%%%%%%%%%%%%%%%%%%%

home = '/home/mdynamics/Desktop/noahSPROJ/';

FileLoc = ['/home/mdynamics/Desktop/noahSPROJ_participants/AllData_Rafidi_Unprocessed/' num2str(parnum) '_CompTrain/']; % change for each participant
cd(FileLoc);
FileList = dir('*.edf');
PreStimTime = 0.5;
PostStimTime = 2;
cd('/home/mdynamics/Desktop/noahSPROJ/processing/Analysis_scripts/');
%for NumFile = 1:length(FileList)
    
    %% Load and read data
    
    %FileName = FileList(NumFile).name;
    FileName = '/home/mdynamics/Desktop/noahSPROJ_participants/5/uncut/5_uncut.edf'; % uncomment for 5
    FullFileName = strcat(FileLoc, '/', FileName);
    %dat = ft_read_data(FullFileName);
    %hdr = ft_read_header(FullFileName);
    dat = ft_read_data(FileName, 'begsample', 1, 'endsample', 323241);
    hdr = ft_read_header(FileName);
    datRS = reshape(dat,size(dat,1),size(dat,2)*size(dat,3)); % Converting 3D (Channel,Samples,Epochs) matrix to 2D (Channel,Samples)
    
    
    %% Identify which numbers were used as triggers for high and low competition trials in this participant
    
    highcomp_triglist_test = [ ];
    lowcomp_triglist_test = [ ];
    study_triglist = [ ];
    
    %-----------STOP HERE------------% 
    %% LOAD Competition.mat
    %cd('/home/mdynamics/Desktop/noahSPROJ/comp-eeg-master/Experiment/');
    
    % Navigate to this participant's folder 
    % LOAD competition.mat
    % Search to find low and high comp
    
    load([home 'comp-eeg-master/Experiment/' num2str(partfolder) '/competition.mat']);

    for x = 1:length(experiment) % look at each block
        cur_exp_port = experiment(x).parPort; % open parPort for this block
        cur_exp_story = experiment(x).story; % open story for this block
        for y = 1:length(cur_exp_port) % look at each cell in parPort for this block
            disp(y);
            [~, allnum_col] = find(cur_exp_port(1, :) > 1); % pull col references for cells with triggers - don't include '1' bc I used '1' as a trigger code when I shouldn't have
            allnum_col(1) = []; % deletes the prompt trigger
            for z = 1:length(allnum_col) % once you find a trigger, find the related prompt
                     current = cur_exp_story(1, allnum_col(z)); % current prompt for the found trigger
                     [a,b] = strtok(current,'-'); % split the prompt by the '-'
                     if length(char(a)) == 2 % if it's presenting the exemplar and asking for the category
                         lowcomp_trig = cur_exp_port(1, allnum_col(z)); % low comp trig
                         isthere = 0;
                         % check to see if trig is in trig lookup list
                         for helper = 1:length(lowcomp_triglist_test)
                             if lowcomp_triglist_test(helper) == lowcomp_trig
                                 isthere = 1;
                                 break;
                             end
                         end
                         % add trig to list if it's not already there
                         if isthere == 0
                             lowcomp_triglist_test(end+1) = lowcomp_trig; % bin this trigger number as low competition trigger
                         end
                     elseif length(char(b)) == 2 % if it's presenting the category and asking for the exemplar - len(4) includes the '--'
                         trig = cur_exp_port(1, allnum_col(z)); % high comp trig
                         isthere = 0;
                         % check to see if trig is in 
                         for helper = 1:length(highcomp_triglist_test)
                             if highcomp_triglist_test(helper) == trig
                                 isthere = 1;
                                 break;
                             end
                         end
                         if isthere == 0
                             highcomp_triglist_test(end+1) = trig; % bin this trigger number as a high competition trigger
                         end
                     end
            end
        end
    end
        
    % -----------STOP HERE------------%          
    %% LOAD presentation.mat

      % These are the same trigger numbers as competition.mat. They're
      % actually defined here, but they're easier to understand whether
      % they're high or low comp triggers when looking at the comp.mat file
      
      load([home 'comp-eeg-master/Experiment/' num2str(partfolder) '/presentation.mat']);

      for x = 1:length(experiment) % look at each block
        cur_exp_port = experiment(x).parPort; % open parPort for this block
        cur_exp_story = experiment(x).story; % open story for this block
        for y = 1:length(cur_exp_port) % look at each cell in parPort for this block
            disp(y);
            [~, allnum_col] = find(cur_exp_port(1, :) > 1); % pull col references for cells with triggers - don't include '1' bc I used '1' as a trigger code when I shouldn't have
            allnum_col(1) = []; % deletes the prompt trigger
            for z = 1:length(allnum_col)
                study_trig = cur_exp_port(1, allnum_col(z)); % high comp trig
                isthere = 0;
                for helper = 1:length(study_triglist)
                    if study_triglist(helper) == study_trig
                        isthere = 1;
                        break;
                    end
                end
                if isthere == 0
                    study_triglist(end+1) = study_trig; % bin this trigger number as a study trigger
                end
            end
        end
      end
      
      
      %% Identify data markers in .edf and find events of interest
      
    %cd('/home/mdynamics/Desktop/noahSPROJ/processing/Analysis_scripts/');
    
    % I LEFT OFF HERE:
    % * Ready to segment the data
    % * confused and concerned that the data I was looking at for compN is
    % not being segmented properly
    % * When I write script to pull from KR, just use the isthere if funcs
    % * I ACTUALLY LEFT OFF TRYING TO SEE IF THE TRIGGERS IN THE STUDY
    % BLOCKS ARE DIFFERENT THAN THE TRIGGERS IN THE QUIZ BLOCKS
    
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
    
    % Trials for Cat/Exemplar
    LowCompStart = []; % Initialize the holding place for trigger locations in .edf data
    for trignum = 1:length(lowcomp_triglist_test)
        newtrig = find(datRS(20, :) == lowcomp_triglist_test(trignum));
        for s = 1:length(newtrig)
            LowCompStart(end+1) = newtrig(s);
        end
    end
    HighCompStart = []; % Initialize the holding place for trigger locations in .edf data
    for trignum = 1:length(highcomp_triglist_test)
        newtrig = find(datRS(20, :) == highcomp_triglist_test(trignum));
        for s = 1:length(newtrig)
            HighCompStart(end+1) = newtrig(s);
        end
    end
    StudyStart = []; % Initialize the holding place for trigger locations in .edf data
    for trignum = 1:length(study_triglist)
        newtrig = find(datRS(20, :) == study_triglist(trignum));
        for s = 1:length(newtrig)
            StudyStart(end+1) = newtrig(s);
        end
    end
    
    %% Epoching/segmentation
    
    % Hold trials
    Trials_LowComp = [];
    Signals_LowComp = [];
    LowComp_TrlInfo = ones(1,length(LowCompStart))*1; % 1 - for later trial id
    for blk = 1:length(LowCompStart)
        Trials_LowComp{blk} = datRS(:,LowCompStart(blk)-PreStimTime*hdr.Fs:LowCompStart(blk)+PostStimTime*hdr.Fs);
        Signals_LowComp{blk} = Trials_LowComp{blk}(3:16, :);
    end
    
    
    Trials_HighComp = [];
    Signals_HighComp = [];
    HighComp_TrlInfo = ones(1,length(HighCompStart))*2; % 2 - for later trial id
    for blk = 1:length(HighCompStart)
        Trials_HighComp{blk} = datRS(:,HighCompStart(blk)-PreStimTime*hdr.Fs:HighCompStart(blk)+PostStimTime*hdr.Fs);
        Signals_HighComp{blk} = Trials_HighComp{blk}(3:16, :);
    end


    Trials_Study = [];
    Signals_Study = [];
    Study_TrlInfo = ones(1,length(StudyStart))*3; % 3 - for later trial id
    for blk = 1:length(StudyStart)
        Trials_Study{blk} = datRS(:,StudyStart(blk)-PreStimTime*hdr.Fs:StudyStart(blk)+PostStimTime*hdr.Fs);
        Signals_Study{blk} = Trials_Study{blk}(3:16, :);
    end

    
    %% Big Data
    
    BigData = [ Trials_LowComp Trials_HighComp ];
    TrlInfoVector = [ LowComp_TrlInfo HighComp_TrlInfo ];
    
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
    %matfile = fullfile('/home/mdynamics/Desktop/noahSPROJ_participants/data/Rafidi/mat', [a '.mat']);
    matfile = fullfile('/home/mdynamics/Desktop/noahSPROJ_participants/data/Rafidi/mat/5_Rafidi_Train.mat');
    save(matfile,'data');
    clear data
    
%end % end full loop



