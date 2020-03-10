function Sproj_Weight_TopoPLots(input)

stat=input;
if isstruct(stat) %if what's loaded in is one subject
avg_weights = zeros(size(stat.model{1,1}.weights));
    for i = 1:length(stat.model)
        avg_weights = (avg_weights + stat.model{i,1}.weights);
    end
avg_weights = (avg_weights/(length(stat.model)));
stat.avg = avg_weights;

elseif iscell(stat)
    avg_weights = zeros(size(stat{1,1}.model{1,1}.weights)); %intialize
    
    for o = 1:length(stat)
    for i = 1:length(stat{3,1}.model)
        avg_weights = (avg_weights+stat{o}.model{i,1}.weights);
    end
    end
    avg_weights = (avg_weights/(i*o));
    stat{1,1}.avg = avg_weights;
end

load('C:\Users\Admin\Desktop\FieldTrip\fieldtrip-20180128\template\layout\easycapM20.mat');

cfg              = [];
figure

%cfg.xlim = [0.9 1.3];                
%cfg.ylim = [15 20];        
%cfg.zlim = [-1e-27 1e-27];  
cfg.gridscale = 200;

cfg.parameter   = 'avg';
cfg.layout      = lay;
cfg.comment      = 'no';
cfg.colorbar     = 'yes';
cfg.interplimits = 'head';

if iscell(stat)
ft_topoplotTFR(cfg,stat{1,1});
elseif isstruct(stat)
ft_topoplotTFR(cfg,stat);
end
end