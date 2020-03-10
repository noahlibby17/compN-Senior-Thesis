function Sproj_topoClusterPlot(lay, stat)

cfg = [];
cfg.zlim = [-5 5]; % T-values
cfg.alpha = 0.05;
cfg.layout = lay;
ft_clusterplot(cfg,stat);
end