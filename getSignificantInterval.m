function [onset,offset] = getSignificantInterval(I,Is,bins,limit,minnbins)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Find the region(s) where the values in I exceed the specified limit 
	%of the distribution of values in Is
	%Input:
	%	I		:		vector of values
	%	Is		:		matrix of ntrials X nvalues, where each column should be compared
	%					to the corresponding column in I
	%	bins	:		the bins in which I and Is are computed
	%	limit	:		the percentile of Ish which I should exceed to be considered
	%					significant
	%	minnbins	:		the number of consecutive bins with I > limit(Ish) for 
	%					the result to be considered significant
	%Output:
	%	onset	:		onset of the significant region(s)
	%	offset	:		offset of the significant region(s)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 5
		minnbins = 5;
	end
	if nargin < 4
		limit = 95;
	end
	sidx = find(I>prctile(Is,limit,1)');
	onset = nan;
	offset = nan;
	if ~isempty(sidx) 
		%find the start of each consectuive segment, i.e. where the difference between 
		%indices is greater than 1
		qidx =[1;find(diff(sidx)>1)];
		if ~isempty(qidx)
			%find the segments with at least 5 bins
			nbins = diff(qidx);
			bidx = find(nbins>minnbins);
			sidx = sidx(qidx(bidx)+1);
			if ~isempty(sidx)
				%identify the onset as the first bin
				onset = bins(sidx(1));
				offset = bins(sidx(1)+nbins(bidx(1))-1);
			end
		end
	end
end
