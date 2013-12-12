function cp = getChoiceProb(counts,trial_labels)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%compute choice probability for a single cell with spike counts as given in counts
	%Input:
	%	counts	[ntrials X nbins] 	:	spike counts for each trial and bin
	%	trial_labels [ntrials]		:	a label for each trial
	%Output:
	%	cp							:	the choice probability
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	ntrials = size(counts,1);
	nbins = size(counts,2);

	ul = unique(trial_labels);
	ngroups = length(ul);
	mu = zeros(ngroups,nbins);
	v = zeros(ngroups,nbins);
	for g=1:ngroups
		idx = trial_labels ==ul(g);
		mu(g,:) = mean(double(counts(idx,:)),1);
		v(g,:) = var(double(counts(idx,:)),0,1);
	end
	%do one against the rest classification
	cp = zeros(ngroups,nbins);
	q = 1/ngroups;
	for g=1:ngroups
		oidx = setdiff(1:ngroups,g);
		d = (mu(g,:) - mean(mu(oidx,:),1))./sqrt(g*(sum(v,1)));
		cp(g,:) = 0.5*erfc(-d/2);
	end
	%d = (mu(1,:) - mu(2,:))./sqrt(0.5*(v(1,:))+ v(2,:));
	%cp = 0.5*erfc(-d/2);
end

