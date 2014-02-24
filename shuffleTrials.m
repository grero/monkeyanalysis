function qcounts = shuffleTrials(counts, trial_labels)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Shuffle trials within each location, such that the simultaneity
	%between the cells in a population is disrupted
	%Input:
	%	counts	:	[ncells X ntrials X nbins] 	: spikec ounts
	%	trial_lables	:	[ntrials]			: location label for each trial
	%Output:
	%	qcounts	:	counts with shuffled trials
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ncells = size(counts,1);
    ntrials = size(counts,2);
    nbins = size(counts,3);
    ul = unique(trial_labels);
    qcounts = zeros(size(counts));
    for i=1:length(ul)
        idx = find(trial_labels==ul(i));
        for c=1:ncells
            lidx = randsample(idx,length(idx));
            qcounts(c,idx,:) = counts(c,lidx,:);
        end
    end
end
