function analyzeLocationInformation(sptrains,trials,bins,alignment_event,sort_event)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute and plot the information for several spike trains. The plots
	%are saved under the current directory as gXXcXXsLocationInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	trials			:		structure array of trial information
	%	bins			:		the bins into which the spike trains should be discretized
	%	alignment_event	:		the event to which to align the spike trains. Defaults 
	%							to target
	%	sort_event		:		the event used to sort the trials. Defaults
	%							to 'target'
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 5
		sort_event = 'target';
	end
	if nargin < 4
		alignment_event = 'target';
	end
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			%get the counts
			[counts,bins] = getTrialSpikeCounts(clusters(j),trials,bins,'alignment_event',alignment_event);
			[H,Hc,bins] = computeInformation(counts,bins,trials,0,sort_event);
			[Hs,Hcs,bins] = computeInformation(counts,bins,trials,1,sort_event);

			plotLocationInformation(H-Hc,bins,alignment_event,trials,Hs-Hcs)
			fname = sprintf('g%.2dc%.2dsLocationInformation.pdf', sptrains.spikechannels(ch),j);
			print('-dpdf',fname);
		end
	end
end