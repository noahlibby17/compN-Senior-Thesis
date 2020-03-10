% make my own trialfun that searches the correct column for the numbers that I'm looking for. Save the correct amount of samples before and after the trigger in a struct or whatever way that fieldtrip reads events

cfg = [];
cfg.method = 'runica';
cfg.dataset = '/home/mdynamics/Desktop/noahSPROJ_participants/1/1_compn_train/1_CompN_Train.edf';
cfg.continous = 'yes';
cfg.channel = 'all';
%cfg.reref = 'yes';
%cfg.rerefchannel = 'all';
cfg.trialfun = 'ft_trialfun_emotiv_edf';
cfg.trialdef.eventtype = '?';
dummy = ft_definetrial(cfg);


[header, recordData] = edfread('/home/mdynamics/Desktop/noahSPROJ_participants/1/1_compn_train/1_CompN_Train.edf');

%%


dataset = [];
tmp_array = recordData(20,:);



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
%CompN RP
LowCompStart_RP = find(datRS(20, :) == 31);
LowCompEnd_RP = find(datRS(20, :) == 32);
HighCompStart_RP = find(datRS(20, :) == 33);
HighCompEnd_RP = find(datRS(20, :) == 34);
% CompN Final Test Phase
LowCompStart_Test = find(datRS(20, :) == 41);
LowCompEnd_Test = find(datRS(20, :) == 42);
HighCompStart_Test = find(datRS(20, :) == 43);
HighCompEnd_Test = find(recordData(20, :) == 44);

