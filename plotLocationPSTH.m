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
        alignto(t) = getfield(trials(t),alignment_event)*1000;
        target(t) = trials(t).target.timestamp*1000;
		target(t) = target(t)-alignto(t);
		rr = trials(t).response*1000 - alignto(t);
		if isempty(rr)
			rr = nan;
		end
		response(t) = rr;
    end
    nrows = max(row);
    ncols = max(column);
    %get the unique locations
    figure;
    centery = (nrows+1)/2;
    centerx= (ncols+1)/2;
	db = mean(diff(bins))/1000;
	figure
    for r=1:nrows
        for c=1:ncols
            if (r==centery) && (c == centerx)
                continue
            end
            subplot(nrows,ncols,(r-1)*ncols+c)
            idx = (row==r)&(column==c);
			M = mean(counts(idx,:),1)/db;
			S = std(counts(idx,:),1)/db;
			plot(bins,M);
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
        end
    end
end
