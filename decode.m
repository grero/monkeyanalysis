function [class_errs,decoded,actual,coeffs,P,trials] = decode(counts,trial_labels,runs,type,trial_shuffle)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Decode the trial labels using joint counts
	%Input:
	%	counts	[ncells X ntrials X nbins ]		:	spike counts for multiple cells over multiple bins
	%	trial_labels	[ntrials]				:	label for each trial, used to group the trials
	%	runs									:	number of re-sampling runs
	%	type									:	the type of decoding algorithm to use. Defaults to 'linear', which is a linear discriminant with pooled covariance matrix.
	%												See 'help classify' for other possible decoding algorithms
	%	trial_shuffle							:	indicate whether to shuffle trials within condition in the training phase. This breaks up any trial-by-trial relationship between cells and results in a decoder that 
	%												is insensitive to the correlation structure between cells
	%Output:
	%	class_errs	[ncats X nbins X nruns]		:	the relative number of errors made by the decoder for each category in each run
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	if nargin < 5
		trial_shuffle = 0;
	end
    if nargin < 4
        type = 'linear';
    end
    n = length(trial_labels);
    nbins = size(counts,3);
    err = zeros(nbins,runs);
    ntrain = floor(0.8*n); %number of training samples
    ntest = n-ntrain; %number of test samples
    decoded = nan*zeros(ntest,nbins,runs); %test result
    actual = nan*zeros(ntest,runs); %test result
	trials = zeros(ntest,runs);
    class_errs = nan*zeros(length(unique(trial_labels)),nbins,runs); %errors per class
	P = nan*zeros(ntest,size(class_errs,1),nbins,runs);
    ul = unique(trial_labels); %unique trial labels
	coeffs = {};
    for k=1:runs
        idx = randsample(1:n,ntrain); %grab a random set of trial for training
        tidx = setdiff(1:n,idx); %grab the remaining trials for testing
		actual(:,k) = trial_labels(tidx);
		trials(:,k) = tidx;
        for i=1:nbins
            try
                if ~trial_shuffle
                    [decoded(:,i,k),er,P(:,:,i,k),logp,coeffs{k}{i}] = classify(squeeze(counts(:,tidx,i))',squeeze(counts(:,idx,i))',trial_labels(idx),type);
                else
					%shuffle the training sample; note that since we are shuffling within conditions, the labels remain unchanged
					tcounts = shuffleTrials(counts(:,idx,i),trial_labels(idx));
                    [decoded(:,i,k),er,P(:,:,i,k),logp,coeffs{k}{i}] = classify(squeeze(counts(:,tidx,i))',tcounts',trial_labels(idx),type);
                end
                for j=1:size(class_errs,1)
                    qidx = trial_labels(tidx)==ul(j);
                    class_errs(j,i,k) = sum(decoded(qidx,i,k)~=ul(j))./sum(qidx);
                end
            catch e
                e
            end
        end
        err(:,k) = sum(squeeze(decoded(:,:,k))==repmat(trial_labels(tidx),1,nbins))/ntest;
    end
end
    

    
    
    
