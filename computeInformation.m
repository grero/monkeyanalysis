function [H,Hc,bins] = computeInformation(counts,bins,trials,shuffle)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute the information contained in the counts matrix.
	%Input:
	%	counts		:		[ntrials X nbins-1]		:		matrix of spike counts
	%	bins		:		[nbins,1]				:		the bins use to compute the spike counts
	%	trials		:		structure array containing information about the trials used
	%	shuffle		:		whether we should also compute shuffle information. Defaults to 0 (no)
	%Output:
	%	H			:		Total entropy for each time bin
	%	Hc			:		Conditional entropy for each time bin
	%	bins		:		bins used to compute the spike counts
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin == 3
		shuffle = 0;
	end
	ntrials = size(counts,1);
	trial_labels = zeros(ntrials,1);
	rows = zeros(ntrials,1);
	columns = zeros(ntrials,1);
	for t=1:length(trials)
		rows(t) = trials(t).target.row;
		columns(t) = trials(t).target.column;
	end
	nrows = max(rows);
	ncols = max(columns);
	trial_labels = (rows-1).*ncols + columns;

	nbins = length(bins);
	%get the unique labels
	[u,k,j] = unique(trial_labels);
	ncond = length(u);
	%get the cardinality of the counts
	uc = unique(counts);
	mx = length(uc);
	if ~shuffle
		[H,Hc] = computeEntropies(counts,uc,trial_labels,u,bins);
	else
		H = zeros(100,nbins);
		Hc = zeros(100,nbins);
		for i=1:100
			tl = randsample(trial_labels,length(trial_labels));
			[H(i,:),Hc(i,:)] = computeEntropies(counts,uc,tl,u,bins);
		end
	end

	function [H,Hc] = computeEntropies(counts,unique_counts,trial_labels,unique_labels,bins)
		ncond = length(unique_labels);
		uc = unique_counts;
		mx = length(uc);
		u = unique_labels;
		pC = zeros(nbins,ncond,mx); %conditional
		p = zeros(nbins,mx,1); %unconditional
		H = zeros(nbins,1);
		Hc = zeros(nbins,1);
		for j=1:nbins
			for i=1:ncond
				tidx = trial_labels == u(i);
				c = counts(tidx,j);
				n = histc(c,uc);
				%normalize
				pC(j,i,:) = n/sum(n);
			end
			%construct total probabilities
			p(j,:) = histc(counts(:,j),uc);
			p(j,:) = p(j,:)/sum(p(j,:));

			H(j) = -p(j,:)*log2(p(j,:) + (p(j,:)==0))';
			hc = -sum(pC(j,:,:).*log2(pC(j,:,:)+(pC(j,:,:)==0)),3);
			ns = histc(trial_labels,u);
			Hc(j) = (ns/sum(ns))'*hc'; 
		end
	end
end
