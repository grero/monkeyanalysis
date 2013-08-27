function [n,bins] = computeSpikeCount(sptrains,bins)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Count the number of spikes in in the specified bins
	%Input:
	%	sptrain		:		cell array of spike times in ms	
	%	bins		:		bins 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	ntrains = length(sptrains)	
	nbins = length(bins)
	n = zeros(ntrains,nbins-1)

	for i=1:ntrains
		[n(i,:),b] = histcie(sptrains{i},bins);
	end
end
	
