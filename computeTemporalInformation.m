function [H,Hc,bins,bias] = computeTemporalInformation(counts,bins,word_size,trials,shuffle,sort_event)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute the information contained in the counts matrix.
	%Input:
	%	counts		:		[ntrials X nbins-1]		:		matrix of spike counts
	%	bins		:		[nbins,1]				:		the bins use to compute the spike counts
	%	word_size	:		the number of bins to concatenate when forming words
	%	trials		:		structure array containing information about the trials used
	%	shuffle		:		whether we should also compute shuffle information. Defaults to 0 (no)
	%	sort_event	:		the event used to sort the trials. This defaults to 'target'
	%Output:
	%	H			:		Total entropy for each time bin
	%	Hc			:		Conditional entropy for each time bin
	%	bins		:		bins used to compute the spike counts
	%	bias		:		the Panzeri-Treves bias correction factor for the information
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 5
		sort_event = 'target';
	end
	if nargin < 4
		shuffle = 0;
	end
	ntrials = size(counts,1);
	trial_labels = zeros(ntrials,1);
	rows = zeros(ntrials,1);
	columns = zeros(ntrials,1);
	%get the row and column of the target
	for t=1:length(trials)
		e = getfield(trials(t),sort_event);
        if strcmpi(sort_event,'distractors')
            rows(t) = e(2);
            columns(t) = e(3);
        else
            rows(t) = e.row;
            columns(t) = e.column;
        end
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
		[H,Hc,bias] = computeEntropies(counts,uc,trial_labels,u,bins);
	else
		H = zeros(100,nbins);
		Hc = zeros(100,nbins);
		bias = zeros(100,nbins);
		for k=1:100
			tl = randsample(trial_labels,length(trial_labels));
			[H(k,:),Hc(k,:),bias(k,:)] = computeEntropies(counts,uc,tl,u,bins);
		end
	end

	function [H,Hc,bias] = computeEntropies(counts,unique_counts,trial_labels,unique_labels,bins)
		ncond = length(unique_labels);
		uc = unique_counts;
		mx = length(uc);
		u = unique_labels;
		ntrials = length(trial_labels);
		mxc = max(max(counts))+1;
		cconv = mxc.^(0:word_size-1);
		N = sum(cconv)+1; %maximum word hash
		hash_bins = [0:N-1];
        pC = zeros(nbins,ncond,N); %conditional
		p = zeros(nbins,N,1); %unconditional
		H = zeros(nbins,1);
		Hc = zeros(nbins,1);
		Rs = zeros(nbins,ncond);
		R = zeros(nbins,1);
		bias = zeros(nbins,1);
		for j=1:nbins-word_size
			for i=1:ncond
				tidx = trial_labels == u(i);
				%get 'word_size' bins from the current bin and hash them
				c = counts(tidx,j:j+word_size-1);
				w = c*cconv';
				%count the instances
				n = histc(w,hash_bins);
				%normalize
				pC(j,i,:) = n/sum(n);
				Rs(j,i) = sum(n>0);
			end
			%construct total probabilities
            w = counts(:,j:j+word_size-1)*cconv';
			p(j,:) = histc(w,hash_bins);
			R(j) = sum(p(j,:)>0);
			p(j,:) = p(j,:)/sum(p(j,:));

			H(j) = -p(j,:)*log2(p(j,:) + (p(j,:)==0))';
			hc = -sum(pC(j,:,:).*log2(pC(j,:,:)+(pC(j,:,:)==0)),3);
			ns = histc(trial_labels,u);
			Hc(j) = (ns/sum(ns))'*hc'; 
			%pt bias correction
			%get the number of observerd responses
			bias(j) = 1/(2*ntrials*log(2))*(sum(Rs(j,:)-1,2) - R(j)+1);
		end
	end
end
