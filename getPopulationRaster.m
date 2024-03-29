function [aligned_sptrains, trial_idx, cellidx] = getPopulationRaster(sptrains,trials,window,event)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Return population raster aligned to target onset
	%Input:
	%	sptrains	:	structure containing spike time information for all units
	%	trials		:	structure containing info about the trials
	%	window		:	[min,max] tuple with the analysis window limits. E.g. (-200,1700) will
	%					return spike for all cells falling between -200ms before target onset and 1700ms
	%					after target onset
	%Output:
	%	aligned_sptrains	:	flat array containing spikes falling within the specified window for all cells
	%							and all trials
	%	trial_idx			:	the trial to which each spike belongs
	%	cellidx				:	the cell to which eac spike belongs
	%Example usage:
	%	[aligned_sptrains, trial_idx, cellidx] = getPopulationRaster(sptrains,rtrials,[-200,2300])
	%		return all spikes from the spike trains in sptrains falling between 200 ms before and 2300 
	%		ms after target onset
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	aligned_sptrains = [];
	trial_idx = [];
	cellidx = [];
	k = 1;
    if nargin < 4
        event = 'target';
    end
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for c=1:length(clusters)
			[a,t] = createAlignedRaster(clusters(c),trials,event,window);
			idx = (a>window(1))&(a<window(2));
			aligned_sptrains = [aligned_sptrains a(idx)];
			trial_idx = [trial_idx t(idx)];
			cellidx = [cellidx k*ones(1,sum(idx))];
			k = k+1;
		end
	end

end
