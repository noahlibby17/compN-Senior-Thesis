%% Artifact rejection - visual


gather = inputdlg('Which exp. is this dir. for? 1 = Rafidi, 2 = CompN');
if char(gather) == '1'
    c_name = 'Rafidi';
elseif char(gather) == '2'
    c_name = 'CompN';
end

FileLoc = ['/home/mdynamics/Desktop/noahSPROJ_participants/data/' c_name '/mat/'];
cd(FileLoc);
FileList = dir('*.mat');

cd('/home/mdynamics/Desktop/noahSPROJ/processing/Analysis_scripts/');

for NumFile = 1:length(FileList)
    %% Load .mat file for the participant
    FileName = FileList(NumFile).name;
    load([FileLoc FileName]); % load the .mat file variable dat for this file
    cfg = data.cfg; % get the config
    
    %% Redefine each trial into epochs of 2 seconds
    cfg.length = 2.5;
    cfg.minlength = 2.5;
    cfg.reref = 'yes';
    cfg.refchannel = 'all';
    %cfg.trials = 'all';
    %dataredef = ft_redefinetrial(cfg, data);
    
    %% Bandpass filter - redefine these filters probably?
    cfg.bpfilter        = 'yes';
    cfg.bpfreq          = [0.1 30]; % good filter
    cfg.bptype          = 'but'; % butter
    cfg.bpfiltord       = 2; % what does this mean
    cfg.bpfiltdir       = 'twopass'; % what does this mean
    cfg.demean          = 'yes'; % what does this mean
    cfg.detrend         = 'yes'; % what does this mean
    
    [preproc] = ft_preprocessing(cfg, data);
    
    %% eye blinks
    
    % channel selection, cutoff and padding
    cfg.artfctdef.zvalue.channel     = 'AF3';
    cfg.artfctdef.zvalue.cutoff      = 4;
    cfg.artfctdef.zvalue.trlpadding  = 0;
    cfg.artfctdef.zvalue.artpadding  = 0.1;
    cfg.artfctdef.zvalue.fltpadding  = 0;
    
    % algorithmic parameters
    cfg.artfctdef.zvalue.bpfilter   = 'yes';
    cfg.artfctdef.zvalue.bpfilttype = 'but';
    cfg.artfctdef.zvalue.bpfreq     = [2 15];
    cfg.artfctdef.zvalue.bpfiltord  = 4;
    cfg.artfctdef.zvalue.hilbert    = 'yes';
    
    % feedback
    cfg.artfctdef.zvalue.interactive = 'yes';
    
    [finalcfg, artifact_blinks] = ft_artifact_zvalue(cfg, data);
    
    %% Save it
    finalcfg.artfctdef.reject = 'complete'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
    finalcfg.artfctdef.eog.artifact = artifact_blinks; %
    %finalcfg.artfctdef.jump.artifact = artifact_jump;
    %finalcfg.artfctdef.muscle.artifact = artifact_muscle;
    data_no_artifacts = ft_rejectartifact(finalcfg, data);
    
    [a, b] = strtok(FileName, '.');
    matfile = fullfile(['/home/mdynamics/Desktop/noahSPROJ_participants/data/' c_name '/CleanedHolding/' a '_cleaned.mat']);
    save(matfile,'data_no_artifacts');
end
