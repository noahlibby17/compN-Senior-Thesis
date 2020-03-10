function [trl, event] = trialfun_annotation(cfg)

% read the header, this is needed to determine the sampling rate of EEG channels
hdr = ft_read_header(cfg.dataset);

% read the events, don't detect flanks in a trigger channel but read annotations
event = ft_read_event(cfg.dataset, 'detectflank', [], 'trigindx', 20);

% make a selection of the Stimulus annotations
sel = ismember({event.value}, {'Stimulus'});



% determine the sample numbers of events
smp = [event(sel).sample];

begsample = smp-round(0.250*hdr.Fs);
endsample = smp+round(0.750*hdr.Fs);
offset    = -ones(size(begsample))*round(0.250*hdr.Fs);

trl = [begsample(:) endsample(:) offset(:)];

% remove trials that overlap with the beginning of the file
sel = trl(:,1)>1;
trl = trl(sel,:);

% remove trials that overlap with the end of the file
sel = trl(:,2)<hdr.nSamples;
trl = trl(sel,:);