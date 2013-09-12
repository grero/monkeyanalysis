function [onset,offset] = analyzeResponseOnset(sptrains,trials,bins,alignment_event,sort_event)
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
	%Output:
	%	onset			:		array of response onsets for each spike train
	%	offset			:		array of response offsets for each spike train
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 5
		sort_event = 'target';
	end
	if nargin < 4
		alignment_event = 'target';
	end
	ncells = sptrains.ntrains;
	onset = zeros(ncells,1);
	offset = zeros(ncells,1);
	k = 1;
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			[onset(k),offset(k)] = getResponseOnset(clusters(j),bins,trials,alignment_event,sort_event);
			k = k+1;
		end
	end
end
