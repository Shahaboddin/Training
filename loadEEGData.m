ft_defaults;
fileName = 'Test_4.edf';
cfg				= [];
cfg.dataset 	= fileName;
cfg.header		= ft_read_header(cfg.dataset);
labels			= cfg.header.label(3:end);
data_events		= ft_read_event(cfg.dataset,'header',cfg.header,...
	'detectflank','up','chanindx',3:10,'threshold','(1/2)*nanmedian');
events = [];
for i = 1:length(labels)
	idx = cellfun(@(x)strcmpi(x,labels{i}),{data_events.type});
	events(i).label	= labels{i};
	events(i).idx	= idx;
	events(i).e		= data_events(idx);
end
	

if ~exist('data_eeg','var')
	cfg.continuous	= 'yes';
	cfg.channel 	= 'all';
	data_eeg		= ft_preprocessing(cfg);
end

nchan = length(data_eeg.label);
offset = 0;

h = figure('Name',fileName,'Units','normalized','Position',[0.1 0.1 0.8 0.8]);
tl = tiledlayout(h,nchan,1,'TileSpacing','compact','Padding','none');

tm = data_eeg.time{1};
for i = 1:nchan
	ch{i} = data_eeg.trial{1}(i+offset,:);
	baseline = median(ch{i}(1:100));
	ch{i} = (ch{i} - baseline);
	ch{i} = ch{i} / max(ch{i});
	nexttile(tl,i)
	ph{i} = plot(tm,ch{i},'k-');
	title(data_eeg.label{i});
	set(gca,'ButtonDownFcn',@myCallback);
end

tl.XLabel.String = 'Time (s)';
tl.YLabel.String = 'Normalised Amplitude';

xl = [20 30];
for i=1:nchan
	nexttile(tl,i);
	xlim(xl);
	ylim([-0.05 1.05]);
end

function myCallback(src,~)
	xl = src.XLim;
	for i = 1:length(src.Parent.Children)
		src.Parent.Children(i).YLim = [-0.05 1.05];
		if ~all(xl == src.Parent.Children(i).XLim)
			src.Parent.Children(i).XLim = xl;
		end
	end
end