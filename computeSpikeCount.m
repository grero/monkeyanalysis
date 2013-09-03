function [n,bins] = computeSpikeCount(sptrains,bins,overlap)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Count the number of spikes in in the specified bins
	%Input:
	%	sptrain		:		cell array of spike times in ms	
	%	bins		:		bins 
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin == 2
		overlap = 0;
	end
	ntrains = length(sptrains);	
	nbins = length(bins);
	if overlap == 0
		n = zeros(ntrains,nbins-1);
		for i=1:ntrains
			[n(i,:),b] = histcie(sptrains{i},bins);
		end
	else
		bs = diff(bins);
		%find the total length of the bins with overlap, e.g. if bin size is 20 ms and overlap is 10 ms,
		%the length would be lenth(bins)*2
		steps = bs(1)/overlap;
		nn = (length(bins))*bs(1)/overlap;
		n = zeros(ntrains,nn+1);
		for i=1:ntrains
			for j=1:steps	
				n(i,j:steps:end-(steps-j)) = histc(sptrains{i},bins+(j-1)*overlap);
			end
		end
	end
end
	
