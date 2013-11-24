function plotPopulationRaster(aligned_spikes,trial_idx,cell_idx, trials_to_plot)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot the population raster returned by getPopulationRaster
	%Input:
	%	aligned_spikes	:	flat array with all spikes from all cells and all trials
	%	trial_idx		:	the trial index of ecah spike
	%	cell_idx		:	the unit from which each spike was elicited
	%	trials_to_plot	:	array of trials to plot
	%Example:
	% 	plotPopulationRaster(aligned_sptrains,trial_idx,cellidx,find(trial_labels==17))
	%		plots all spikes from all cells for trials at position 17
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%get the indices of the trials to plot
	idx = find(ismember(trial_idx,trials_to_plot));
	trials = trial_idx(idx);
	cells = cell_idx(idx);
	spikes = aligned_spikes(idx);
	[u,j,k] = unique(trials);
	%k now holds the rank of the trials
	ntrials = max(k);
	[cc,cj,ck] = unique(cells);
	ncells = length(cc);
	%construct a y-vector
	y = ck.*ntrials + k;
	%get the cell
	figure
	hold all
	for c=1:ncells
		cidx = cells==c;
		plot(spikes(cidx),y(cidx),'.');
	end
	set(gca,'TickDir','out','Box','Off')
	xlabel('Time [ms]')
end

