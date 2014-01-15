function idx = getAreaSpiketrainIndex(sptrains, channels)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Get the spike train index for specific channels
	%Input:
	%	sptrains	:		a structure containing all the spike trains
	%	channels	:		the chnanels for which we want to return spike
	%	trains
	%Output:
	%	idx	:	the index of the spike trains for the specified channels 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
	ntrains = 0;
	out_sptrains.ntrains = ntrains;
	%get those of the requested channels with spikesh
	k = 0;
	idx = [];
	for ch = 1:length(sptrains.spikechannels)
		channel = sptrains.spikechannels(ch);
		clusters = sptrains.channels(channel).cluster;
		for i=1:length(clusters)
			k = k+1;
			if ismember(channel, channels)
				idx = [idx k];
			end
		end
		
	end
end
