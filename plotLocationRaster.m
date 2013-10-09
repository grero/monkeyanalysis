function plotLocationRaster(spikes,trial_idx,trials,alignment_event,regroup)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot raster with trials arranged according to location
	%Input:
	%	spikes		:		timestamps of spikes to be plotted, in
	%						units of ms
	%	trial_idx	:		the trial index of spike
	%	trials		:		structure array containing information about the 
	%						trials used to aligned the spikes
	%	alignment_event:	the event used to align the spikes, .e.g. 'target'
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 5
        regroup = 0;
    end
	%get the distribution of response period onsets
	response = nan*zeros(length(trials),1);
	row = zeros(length(trials),1);
	column = zeros(length(trials),1);
	for t=1:length(trials)
		
		alignto = getfield(trials(t),alignment_event);
		if isstruct(alignto)
			alignto = alignto.timestamp;
        end
        
		row(t) = trials(t).target.row;
		column(t) = trials(t).target.column;
        if ~isempty(trials(t).response)
            response(t) = trials(t).response;
            response(t) = (response(t)-alignto)*1000;
        end
    end
    if ~regroup
        row = row-min(row)+1;
        column = column - min(column)+1;
        %figure out the maximum/minimum row
    else
        [trial_labels,row,column] = regroupTrials(trials);
    end
    nrows = max(row);
    ncols = max(column);
    %[trial_labels,ridx] = sort(trial_labels);
    %row = row(ridx);
    %column = column(ridx);
	R = nanmedian(response);
	Rv = prctile(response(~isnan(response)),[25,75]);
    rl = Rv(1);
    rh = Rv(2);
	figure
	set(gcf,'PaperOrientation','landscape')
	%show spikes that are at least 200 ms before trigger and at most 
	%3000 ms after the trigger
	sidx = (spikes > -200)&(spikes < 3000);
	width = 0.9/nrows;
    for r=1:nrows
        for c=1:ncols
			qidx = sidx&(row(trial_idx)==r)'&(column(trial_idx)==c)';
            if sum(qidx) == 0
                continue
            end
            %h = subplot(nrows,ncols,(r-1)*ncols + c);
			h = subplot('Position',[0.05 + (c-1)*width,0.95 - r*width, 0.9*width, 0.9*width]);
			plot(h,spikes(qidx),trial_idx(qidx),'.','MarkerSize',5);
            xlim([-200,3000]);
            ylim([0,length(row)]);
			if  r == nrows && c ==1 
				xlabel('Time [ms]');
				ylabel('Trial')
			else
				set(gca,'XTickLabel',[]);
				set(gca,'YTickLabel',[]);
			end
			set(gca,'Box','Off');
			set(gca,'TickDir','out');

			yl = ylim;
			%indicate zero
			hold on
			plot([0 0],[yl(1), yl(2)],'k');
			h1 = plot([R,R], [yl(1),yl(2)],'r','linewidth',2);
			h2 = plot([rl,rl], [yl(1),yl(2)],'r');
			h3 = plot([rh,rh], [yl(1),yl(2)],'r');
		end
	end
	%legend(h1,'Median response period onset','Location','SouthWest');
end

