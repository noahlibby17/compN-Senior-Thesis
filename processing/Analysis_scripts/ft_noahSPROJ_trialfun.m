function [trl, event] = ft_noahSPROJ_trialfun(cfg)

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = ft_read_event(cfg.dataset);

% ------------------- %

%%% TRIGGER CODES FOR ANIMALS & ITEMS %%%

%%% CompN Exposure
LowCompStart_Exp = [11];
%LowCompEnd_Exp = [12];
HighCompStart_Exp = [13];
%HighCompEnd_Exp = [14];

%%% CompN Study
LowCompStart_Study = [21];
%LowCompEnd_Study = [22];
HighCompStart_Study = [23];
%HighCompEnd_Study = [24];

%%% CompN RP
LowCompStart_RP = [31];
%LowCompEnd_RP = [32];
HighCompStart_RP = [33];
%HighCompEnd_RP = [34];

%%% CompN Final Test Phase
LowCompStart_Test = [41];
%LowCompEnd_Test = [42];
HighCompStart_Test = [43];
%HighCompEnd_Test = [44];

%%% TRIGGER CODES FOR RAFIDI PHASES %%%

Rafidi_Trigger = [1];

% -------------------- %



% search for "trigger" events
value  = [event(find(strcmp('trigger', {event.type}))).value]';
sample = [event(find(strcmp('trigger', {event.type}))).sample]';

% determine the number of samples before and after the trigger
pretrig  = -round(cfg.trialdef.pre  * hdr.Fs);
posttrig =  round(cfg.trialdef.post * hdr.Fs);

% look for the combination of a trigger "7" followed by a trigger "64"
% for each trigger except the last one
trl = [];
for j = 1:(length(value)-1)
    trg1 = value(j);
    trg2 = value(j+1);
    if trg1==7 && trg2==64
        trlbegin = sample(j) + pretrig;
        trlend   = sample(j) + posttrig;
        offset   = pretrig;
        newtrl   = [trlbegin trlend offset];
        trl      = [trl; newtrl];
    end
end