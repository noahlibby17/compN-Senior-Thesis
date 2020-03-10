function Sproj_analysisPipe_plotStats_topoER(stat,lay)

%% ft_topoplotER
stat.mymodel = stat.model{1}.weights;
load('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128\template\layout\easycapM20.mat');

cfg              = [];
figure
cfg.parameter   = 'mymodel';
cfg.layout      = lay;
cfg.comment      = '';
cfg.colorbar     = 'yes';
cfg.interplimits = 'head';
ft_topoplotTFR(cfg,stat);
end