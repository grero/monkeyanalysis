function [onset,offset] = getResponseOnset(sptrain,bins,trials,alignment_event,sort_event)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute the response onset of the a cell by identifying where the information
	%about target locatoin exceeds the 95th percentile of the shuffled information
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
	%find where I exceeds 95th percentile of Is
	sidx = find(I>prctile(Is,95,1)');
	onset = nan;
	offset = nan;
	if ~isempty(sidx) 
		%find the start of each consectuive segment, i.e. where the difference between 
		%indices is greater than 1
		qidx =find(diff(sidx)>1);
		if ~isempty(qidx)
			%find the segments with at least 5 bins
			nbins = diff(qidx);
			sidx = sidx(qidx(nbins>5)+1);
			if ~isempty(sidx)
				%identify the onset as the first bin
				onset = bins(sidx(1));
				offset = bins(sidx(1)+nbins(1)-1);
			end
		end
	end
end

