function [trl, event] = ft_trialfun_emotiv_edf(cfg)

% FT_TRIALFUN_EDF is an example trial function. It searches for events
% of type "up" in an analog data channel, as indentified by thresholding. 
% This threshold can be a hard threshold, i.e. a numeric, or flexibly defined 
% by an executable string (e.g., calculating the 'median' of an analog signal.
% 
% You can use this example trial function as template for your own
% conditial trial definitions.
%
% See also FT_DEFINETRIAL, FT_PREPROCESSING

if strcmp(mfilename,'ft_trialfun_edf')
  ft_warning('this trial function is only an example, please copy it and adapt it to your specific EDF situation - see http://www.fieldtriptoolbox.org/getting_started/edf');
end

% read the header information
hdr           = ft_read_header(cfg.dataset);

% read the events from the data
chanindx      = 20;
detectflank   = [];
%threshold     = '(3/2)*nanmedian'; % or, e.g., 1/2 times the median for down flanks
%trigindx      = 20;
event         = ft_read_event(cfg.dataset, 'chanindx', chanindx, 'detectflank', detectflank);
a = event;
disp(a);

% define trials around the events
trl           = [];
pretrig       = 0.5 * hdr.Fs; % e.g., 0.5 sec before trigger
posttrig      = 2 * hdr.Fs; % e.g., 2 sec after trigger
for i = 1:numel(event)
    offset    = -hdr.nSamplesPre;  % number of samples prior to the trigger
    trlbegin  = event(i).sample - pretrig;
    trlend    = event(i).sample + posttrig;
    newtrl    = [trlbegin trlend offset];
    trl       = [trl; newtrl]; % store in the trl matrix
end
