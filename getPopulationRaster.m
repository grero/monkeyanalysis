function [aligned_sptrains, trial_idx, cellidx] = getPopulationRaster(sptrains,trials,window)
	aligned_sptrains = [];
	trial_idx = [];
	cellidx = [];
	k = 1;
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for c=1:length(clusters)
			[a,t] = createAlignedRaster(clusters(c),trials,'target');
			idx = (a>window(1))&(a<window(2));
			aligned_sptrains = [aligned_sptrains a(idx)];
			trial_idx = [trial_idx t(idx)];
			cellidx = [cellidx k*ones(1,sum(idx))];
			k = k+1;
		end
	end

end
