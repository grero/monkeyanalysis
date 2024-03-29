function [onset,offset] = getResponseOnset(sptrain,bins,trials,alignment_event,sort_event)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute the response onset of the a cell by identifying where the information
	%about target location exceeds the 95th percentile of the shuffled information
	%for at least 5 bins
	%Input:
	%	sptrain			:		structure with a field 'spiketimes' corresponding to the 
	%							spike times of this cell
	%	bins			:		bins used to compute spike counts
	%	trials			:		structure array with trial information
	%	alignment_event	:		event used to align the spikes. Defaults to 'target'
	%	sort_event		:		event used to sort the trials. Defaults to the same as 
	%							alignment event
	%Output:
	%	onset			:		the response onset of the cell, relative to alignment_event
	%	offset			:		the end of the response period, i.e. where the information drops
	%							below the 95th percentile
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 4
		alignment_event = 'target';
	end
	if nargin < 5
		sort_event = alignment_event;
	end
	[counts,bins] = getTrialSpikeCounts(sptrain,trials,bins,'alignment_event',alignment_event);
	[H,Hc,bins,bias] = computeInformation(counts,bins,trials,0,sort_event);
	[Hs,Hcs,bins,bias] = computeInformation(counts,bins,trials,1,sort_event);
	I = H-Hc;
	Is = Hs-Hcs;
	%find where I exceeds 97.5th percentile of Is
	[onset,offset] = getSignificantInterval(I,Is,bins,97.5,5);
end

