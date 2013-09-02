function analyzeResponseFields(sptrains,trials,bins,alignment_event)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute and plot the information for several spike trains. The plots
	%are saved under the current directory as gXXcXXsLocationInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	trials			:		structure array of trial information
	%	bins			:		the bins into which the spike trains should be discretized
	%	alignment_event	:		the event to which to align the spike trains
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			%get the counts
			[counts,bins] = getTrialSpikeCounts(clusters(j),trials,bins,alignment_event);
			F = computeSpatioTemporalFields(counts,bins,'target',trials);
			%get bins 50 ms to 200 ms after target onset
			idx = (bins<200)&(bins>-50);
			plotResponseFields(F(:,:,idx));
			%use png before pdf and eps look very strange
			fname = sprintf('g%.2dc%.2dsResponseFields.png', sptrains.spikechannels(ch),j);
			print('-dpng',fname);
		end
	end
end
