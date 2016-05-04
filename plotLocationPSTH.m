function plotLocationPSTH(counts,bins,alignment_event,trials)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot raster for different target locations
	%Input:
	%	counts			:	[ntrials X nbins] matrix of spike counts
	%	bins			:	the bins used to compute the spike counts
	%	alignment_event	:	the event to which the spike counts were 
	%						aligned
	%	trials			:	structure array of trials information
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %get the locations
    row = -1*ones(length(trials),1);
    column = -1*ones(length(trials),1);
    alignto = zeros(1,length(trials));
    target = zeros(1,length(trials));
    response = zeros(1,length(trials));
    for t=1:length(trials)
        row(t) = trials(t).target.row;
        column(t) = trials(t).target.column;
        a = getfield(trials(t),alignment_event);
        if isstruct(a)
            alignto(t) = a.timestamp;
        else
            alignto(t) = a;
        end
        alignto(t) = alignto(t)*1000;
        target(t) = trials(t).target.timestamp*1000;
		target(t) = target(t)-alignto(t);
		rr = trials(t).response*1000 - alignto(t);
		if isempty(rr)
			rr = nan;
		end
		response(t) = rr;
    end
    row = row - min(row)+1;
    column =column - min(column)+1;
    nrows = max(row);
    ncols = max(column);
    %get the unique locations
    figure;
    centery = (nrows+1)/2;
    centerx= (ncols+1)/2;
	db = mean(diff(bins))/1000;
	figure
	for c=1:ncols %matlab is column major
		for r=1:nrows
            if (r==centery) && (c == centerx)
                continue
            end
            subplot(nrows,ncols,(r-1)*ncols+c)
            idx = (row==r)&(column==c);
			M = mean(counts(idx,:),1)/db;
			S = std(counts(idx,:),1)/db;
			plot(bins(1:length(M)),M);
			xlim([bins(1) bins(end)]);
            tidx = find(idx);
            t = median(target(tidx));
			p = 0;
			rsp = nanmedian(response(tidx));
            hold on
            yl = ylim;
			plot([p,p],[yl(1) yl(2)],'b');
            plot([t t],[yl(1) yl(2)],'r');
            plot([rsp,rsp],[yl(1) yl(2)],'k');
			%prettify plot
			set(gca, 'Box','off')
			set(gca, 'TickDir','out');
			if (r==nrows) && (c==1)
				xlabel('Time [ms]')
				ylabel('Trial #')
			end
        end
    end
	%prepare figure for printing
	set(gcf,'PaperOrientation','Landscape','PaperPositionMode','auto')
end
