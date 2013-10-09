function [trial_labels,row,column] = regroupTrials(trials)
	ntrials = length(trials);
	row = zeros(ntrials,1);
	column = zeros(ntrials,1);
	for i=1:ntrials
		if ~isempty(trials(i).target)
			row(i) = trials(i).target.row;
			column(i) = trials(i).target.column;
		end
	end
	row = row - min(row) + 1;
	column = column - min(column) + 1;
	nrows = max(row);
	ncols = max(column);
	trial_labels = zeros(ntrials,1);
	trial_labels((row==1 | row == 2) & (column==1 | column==2)) = 1;
	trial_labels((row==1 | row == 2) & (column==3)) = 2;
	trial_labels((row==1 | row == 2) & (column==4 | column==5)) = 3;
	trial_labels((row==3) & (column==4 | column==5)) = 4;
	trial_labels((row==4 | row == 5) & (column==4 | column==5)) = 5;
	trial_labels((row==4 | row==5) & (column==3)) = 6;
	trial_labels((row==4 | row == 5) & (column==1 | column==2)) = 7;
	trial_labels((row==3) & (column==1 | column==2)) = 8;
    
    row(trial_labels==1) = 1;
    column(trial_labels==1) = 1;
    
    row(trial_labels==2) = 1;
    column(trial_labels==2) = 2;
    
    row(trial_labels==3) = 1;
    column(trial_labels==3) = 3;
    
    row(trial_labels==4) = 2;
    column(trial_labels==4) = 3;
    
    row(trial_labels==5) = 3;
    column(trial_labels==5) = 3;
    
    row(trial_labels==6) = 3;
    column(trial_labels==6) = 2;
    
    row(trial_labels==7) = 3;
    column(trial_labels==7) = 1;
    
    row(trial_labels==8) = 2;
    column(trial_labels==8) = 1;
end
