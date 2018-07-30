function [row,column] = getTrialLabels(trials,event, lmap,rescale,nrows,ncols)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Input:
	%	trials		:		trial structure containing trial information
	%	event		:		the event to use when assigning labels
	%	lmap		:		optional mapping between position and label
	%	rescale		:		indicate whether to rescale the row/column to the used range. Default: true
	%Output:
	%	label		:		labels for each trial based on target location
	%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 2
		event = 'target';
    end
    if nargin < 3
        lmap = '';
    end
	if nargin < 3
		rescale = true;
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
	if rescale
		row = row-nanmin(row)+1;
		column = column-nanmin(column)+1;
	end
	if nargin < 5
		nrows = nanmax(row);
	end
	if nargin < 6
		ncols = nanmax(column);
	end
	if nargout == 1
		labels = (column-1)*nrows + row;
		row = labels;
	end
end
