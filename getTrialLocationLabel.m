function labels = getTrialLocationLabel(trials)
	ntrials = length(trials);
	row = nan*zeros(ntrials,1);
	column = nan*zeros(ntrials,1);
	for t=1:ntrials
		if ~isempty(trials(t).target)
			row(t) = trials(t).target.row;
			column(t) = trials(t).target.column;
		end
	end
	row = row - min(row) + 1;
	nrows = max(row);
	column = column - min(column)+1;
	ncols = max(column);
	labels = (row-1)*ncols + column;
end
