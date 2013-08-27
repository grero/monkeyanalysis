function analyzeLocationInformation(sptrains,trials,bins,alignment_event)
	
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			%get the counts
			[counts,bins] = getTrialSpikeCounts(clusters(j),trials,bins,alignment_event);
			[H,Hc,bins] = computeInformation(counts,bins,trials,0);
			[Hs,Hcs,bins] = computeInformation(counts,bins,trials,1);

			plotLocationInformation(H-Hc,bins,alignment_event,trials,Hs-Hcs)
			fname = sprintf('g%.2dc%.2dsLocationInformation.pdf', sptrains.spikechannels(ch),j);
			print('-dpdf',fname);
		end
	end
end
