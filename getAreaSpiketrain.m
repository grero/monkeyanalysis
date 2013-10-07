function out_sptrains = getAreaSpiketrain(sptrains, channels)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Get the spike trains for specific channels
	%Input:
	%	sptrains	:		a structure containing all the spike trains
	%	channels	:		the chnanels for which we want to return spike trains
	%Output:
	%	out_sptrains	:	the spike trains from the specified channels
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	ntrains = 0;
	out_sptrains.ntrains = ntrains;
	%get those of the requested channels with spikesh
	cchannels = intersect(channels,sptrains.spikechannels);
	if ~isempty(cchannels) 
		for ch = 1:length(cchannels)
            cluster = sptrains.channels(cchannels(ch)).cluster;
            ntrains = ntrains + length(cluster);
			out_sptrains.channels(cchannels(ch)).cluster = cluster;
			
		end
	end
	out_sptrains.spikechannels = cchannels;
	out_sptrains.ntrains = ntrains;
end
