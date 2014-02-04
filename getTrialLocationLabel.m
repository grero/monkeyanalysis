function [row,column] = getTrialLocationLabel(trials,event)
	if nargin < 2
		event = 'target';
	end
	ntrials = length(trials);
	row = nan*zeros(ntrials,1);
	column = nan*zeros(ntrials,1);
	for t=1:ntrials
		if ~isempty(getfield(trials(t),event))
			row(t) = getfield(trials(t),event).row;
			column(t) = getfield(trials(t),event).column;
		end
	end
	row = row - min(row) + 1;
	nrows = max(row);
	column = column - min(column)+1;
	ncols = max(column);
	labels = (row-1)*ncols + column;
end
