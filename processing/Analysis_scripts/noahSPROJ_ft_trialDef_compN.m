
% Add fieldtrip and its subfolders to the path
addpath /home/mdynamics/Documents/Matlab_offcampus/fieldtrip
ft_defaults;

% Participant 5 CompN Learn and Rafidi Train were recorded in the same .edf
% file. We need to separate them, which is why there are some lines of code
% specifically for dealing with that file.

%%%%%%%%%%%%%%%%%%%%

FileLoc = '/home/mdynamics/Desktop/noahSPROJ_participants/AllData_CompN_Unprocessed';
cd(FileLoc);
FileList = dir('*.edf');
PreStimTime = 0.5;
PostStimTime = 2;
cd('/home/mdynamics/Desktop/noahSPROJ/processing/Analysis_scripts/');

for NumFile = 1:length(FileList)
    
    %% Load and read data
    
    FileName = FileList(NumFile).name;
    %FileName = '/home/mdynamics/Desktop/noahSPROJ_participants/5/uncut/5_uncut.edf';
    FullFileName = strcat(FileLoc, '/', FileName);
    dat = ft_read_data(FullFileName);
    hdr = ft_read_header(FullFileName);
    %dat = ft_read_data(FileName, 'begsample', 323242, 'endsample', 447872); % uncomment when running participant 5
    %hdr = ft_read_header(FileName); % uncomment when running participant 5, bc it had two tasks in one and we need to split it
    datRS = reshape(dat,size(dat,1),size(dat,2)*size(dat,3)); % Converting 3D (Channel,Samples,Epochs) matrix to 2D (Channel,Samples)
    
    
    %% Identify data markers and events of interest
    
    % CompN Exposure
    LowCompStart_Exp = find(datRS(20, :) == 11);
    LowCompEnd_Exp = find(datRS(20, :) == 12);
    HighCompStart_Exp = find(datRS(20, :) == 13);
    HighCompEnd_Exp = find(datRS(20, :) == 14);
    % CompN Study
    LowCompStart_Study = find(datRS(20, :) == 21);
    LowCompEnd_Study = find(datRS(20, :) == 22);
    HighCompStart_Study = find(datRS(20, :) == 23);
    HighCompEnd_Study = find(datRS(20, :) == 24);
    % CompN RP
    LowCompStart_RP = find(datRS(20, :) == 31);
    LowCompEnd_RP = find(datRS(20, :) == 32);
    HighCompStart_RP = find(datRS(20, :) == 33);
    HighCompEnd_RP = find(datRS(20, :) == 34);
    % CompN Final Test Phase
    LowCompStart_Test = find(datRS(20, :) == 41);
    LowCompEnd_Test = find(datRS(20, :) == 42);
    HighCompStart_Test = find(datRS(20, :) == 43);
    HighCompEnd_Test = find(datRS(20, :) == 44);
    
    %% Epoching/segmentation

    % Hold trials
    Trials_LowComp_RP = [];
    Signals_LowComp_RP = [];
    LowComp_RP_TrlInfo = ones(1,length(LowCompStart_RP))*4; % 4 - for later trial id
    for blk = 1:length(LowCompStart_RP)
        Trials_LowComp_RP{blk} = datRS(:,LowCompStart_RP(blk)-PreStimTime*hdr.Fs:LowCompStart_RP(blk)+PostStimTime*hdr.Fs);
        Signals_LowComp_RP{blk} = Trials_LowComp_RP{blk}(3:16, :);
    end
    
    
    Trials_HighComp_RP = [];
    Signals_HighComp_RP = [];
    HighComp_RP_TrlInfo = ones(1,length(HighCompStart_RP))*5; % 5 - for later trial id
    for blk = 1:length(HighCompStart_RP)
        Trials_HighComp_RP{blk} = datRS(:,HighCompStart_RP(blk)-PreStimTime*hdr.Fs:HighCompStart_RP(blk)+PostStimTime*hdr.Fs);
        Signals_HighComp_RP{blk} = Trials_HighComp_RP{blk}(3:16, :);
    end


    Trials_LowComp_Test = [];
    Signals_LowComp_Test = [];
    LowComp_Test_TrlInfo = ones(1,length(LowCompStart_Test))*6; % 6 - for later trial id
    for blk = 1:length(LowCompStart_Test)
        Trials_LowComp_Test{blk} = datRS(:,LowCompStart_Test(blk)-PreStimTime*hdr.Fs:LowCompStart_Test(blk)+PostStimTime*hdr.Fs);
        Signals_LowComp_Test{blk} = Trials_LowComp_Test{blk}(3:16, :);
    end
    
    
    Trials_HighComp_Test = [];
    Signals_HighComp_Test = [];
    HighComp_Test_TrlInfo = ones(1,length(HighCompStart_Test))*7; % 7 - for later trial id
    for blk = 1:length(HighCompStart_Test)
        Trials_HighComp_Test{blk} = datRS(:,HighCompStart_Test(blk)-PreStimTime*hdr.Fs:HighCompStart_Test(blk)+PostStimTime*hdr.Fs);
        Signals_HighComp_Test{blk} = Trials_HighComp_Test{blk}(3:16, :);
    end
    
    %% Big Data
    
    RPData = [ Trials_LowComp_RP Trials_HighComp_RP ];
    RPInfoVector = [ LowComp_RP_TrlInfo HighComp_RP_TrlInfo]; 
    TestData = [ Trials_LowComp_Test Trials_HighComp_Test ];
    TestInfoVector = [ LowComp_Test_TrlInfo HighComp_Test_TrlInfo ];
    
    % Save these in case I need to section the data differently before
    % preprocessing at another point
    BigData_RP = [ Trials_LowComp_RP Trials_HighComp_RP ];
    BDRP_TrlInfoVector = [ LowComp_RP_TrlInfo HighComp_RP_TrlInfo ];
    BigData_Test = [ Trials_LowComp_Test Trials_HighComp_Test ];
    BDT_TrlInfoVector = [ LowComp_Test_TrlInfo HighComp_Test_TrlInfo ];
    
    BigData = [ BigData_RP BigData_Test ];
    TrlInfoVector = [ BDRP_TrlInfoVector BDT_TrlInfoVector ];
    
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
    matfile = fullfile('/home/mdynamics/Desktop/noahSPROJ_participants/data/CompN/mat', [a '.mat']);
    %matfile = fullfile('/home/mdynamics/Desktop/noahSPROJ_participants/data/CompN/mat/5_CompN_Learn.mat'); % uncomment for participant 5
    save(matfile,'data');
    clear data
    
end % end full loop



