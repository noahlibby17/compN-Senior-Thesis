%% ICA
function [ica] = Sproj_ICA(x,hA_hM_5,lA_hM_6,hA_lM_7,lA_lM_8,lay)

cfg = [ ];
cfg.method = 'runica';

if x==5
    ica_input = 'hA_hM_5';
elseif x==6
    ica_input = 'lA_hM_6';
elseif x==7
    ica_input = 'hA_lM_7';
elseif x==8
    ica_input = 'lA_lM_8';
end

ica = ft_componentanalysis(cfg, eval(ica_input));

% plot the components for visual inspection
figure
cfg = [];
cfg.component = 1:14;       % specify the component(s) that should be plotted
cfg.layout      = lay;
cfg.comment   = 'no';
ft_topoplotIC(cfg, ica)
end