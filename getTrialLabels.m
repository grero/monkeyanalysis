function labels = getTrialLabels(trials,event, lmap)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Input:
	%	trials		:		trial structure containing trial information
	%	event		:		the event to use when assigning labels
	%	lmap		:		optional mapping between position and label
	%Output:
	%	label		:		labels for each trial based on target location
	%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 2
		event = 'target';
	end
	ntrials = length(trials);
	labels = zeros(ntrials,1);
	row = zeros(ntrials,1);
	column = zeros(ntrials,1);
	for i=1:ntrials
		if isfield(trials(i),event)
            ee = getfield(trials(i),event);
            if strcmpi(event,'distractors')
                row(i) = ee(2);
                column(i) = ee(3);
            else
                row(i) = ee.row;
                column(i) = ee.column;
            end
		else
			row(i) = nan;
			column(i) = nan;
		end
	end
	if strcmpi(lmap,'LCR')
		column(column<3) = 1;
		column(column==3) = 2;
		column(column>3) = 3;
		row = ones(size(row));
	end
	row = row-nanmin(row)+1
	column = column-nanmin(column)+1
	nrows = nanmax(row);
	ncols = nanmax(column);
	labels = (column-1)*nrows + row;
end
