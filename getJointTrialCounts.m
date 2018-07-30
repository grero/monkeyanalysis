function [counts,bins] = getJointTrialCounts(sptrains,trials,bins,varargin)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Convenience function to get the joint spike counts of the spike trains specified
	%in the cell array 'sptrains'
	%Input:
	%	sptrains		:		cell array, or structure array of spike trains
	%	trials			:		trial timing information
	%	bins			:		bins in which to compute spike counts
	%	varargin		:		optional arguments to getTrialSpikeCounts
	%Output:
	%	counts			:		[ncells X ntrials X nbins] matrix of spike counts
	%	bins			:		the input bins
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nbins = length(bins)-1;
    ntrials = length(trials);
    if iscell(sptrains)
        ncells = length(sptrains);
        counts = zeros(ncells,ntrials,nbins);
        for c=1:ncells
            [counts1,bins] = getTrialSpikeCounts(sptrains{c},trials,bins,varargin{:});
            counts(c,:,:) = counts1;
        end
    else
        ncells = sptrains.ntrains;
        counts = zeros(ncells,ntrials,nbins);
        c = 1;
        for ch=1:length(sptrains.spikechannels)
            clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
            for j=1:length(clusters)
                [counts1,bins] = getTrialSpikeCounts(clusters(j),trials,bins,varargin{:});
								counts(c,:,:) = counts1;
                c = c+1;
            end
        end
    end
                
end
	
	
