function F = computeSpatioTemporalFields(counts,bins,alignment_event,trials)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot raster for different target locations
	%Input:
	%	counts			:	[ntrials X nbins] matrix of spike counts
	%	bins			:	the bins used to compute the spike counts
	%	alignment_event	:	the event to which the spike counts were 
	%						aligned
	%	trials			:	structure array of trials information
	%Output:
	%	F	[nrows X ncols X nbins]	:	mean triggered response for each location
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %get the locations
    row = -1*ones(length(trials),1);
    column = -1*ones(length(trials),1);
    for t=1:length(trials)
        row(t) = trials(t).target.row;
        column(t) = trials(t).target.column;
    end
    nrows = max(row);
    ncols = max(column);
    nbins = size(counts,2);
    centery = (nrows+1)/2;
    centerx= (ncols+1)/2;
	db = mean(diff(bins))/1000;
	F = zeros(nrows,ncols,nbins);
    for r=1:nrows
        for c=1:ncols
            if (r==centery) && (c == centerx)
                continue
            end
            idx = (row==r)&(column==c);
			M = mean(counts(idx,:),1)/db;
			S = std(counts(idx,:),1)/db;
			F(r,c,:) = M;
        end
    end
end
