function [class_errs,decoded,actual,P,test] = decodeCounts(counts,training,testing,trial_labels,type,nruns)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%function [class_errs,decoded,actual] = decodeCounts(counts,training,testing,trial_labels,type,nruns)
	%Decode the counts specified by testing, by training an LDA classifier using the indices specified
	%by traning
	%Input:
	%	counts		:	[ncells X ntrials X nbins ]		: spike counts
	%	training	:									: indices of trials used for training
	%	testing		:									: indices used for testing
	%	trial_labels:									: labels for each trial, i.e. target location
	%	type		:									: the type of discriminant used for decoding. Default
	%													  is 'linear'. See help(classify) for more options
	%   nruns		:									: number of training/testing runs to do. Defaults to 100
	%Output:
	%	class_errs	:	[ncats X nbins X nruns]			: the classification error for each trial category,
	%													  for each bin and run
	%	decoded		:	[ntest X nbins X nruns]			: the decoded category for each test trial and for each run
	%	actual		:	[ntest X nruns]					: the ground truth for the testing set
	%	P			:	[ntest X ncats X nbins X nruns]	:estimate of posterior
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 6
        nruns = 1;
    end
    if nargin < 5
        type = 'linear';
    end
    nbins = size(counts,3);
	if length(testing) == 1 %take testing from training
		ntest = testing;
		testing = training;
	else
		ntest = length(testing);
	end
    ul = unique(trial_labels);
    ntrain = length(training);
    decoded = nan*zeros(ntest,nbins,nruns); %test result
   	actual = nan*zeros(ntest,nruns); %test result
   	test = nan*zeros(ntest,nruns); %test result
    class_errs = nan*zeros(length(ul),nbins,nruns); %errors per class
	P = nan*zeros(ntest,size(class_errs,1),nbins,nruns);
    for k=1:nruns
		if ntest == length(testing)
			%bootrap
			tridx = randsample(training,ntrain,true);
			tidx = randsample(testing,ntest,true);
		else
			tridx = randsample(training,ntrain,true);
			%for testing, bootstrap from those trials not used in training
			tidx = randsample(setdiff(training,tridx),ntest,true);
		end
		test(:,k) = tidx;
		actual(:,k) = trial_labels(tidx);
        for i=1:nbins
            try
                [decoded(:,i,k),err,P(:,:,i,k)] = classify(squeeze(counts(:,tidx,i))',squeeze(counts(:,tridx,i))',trial_labels(tridx),type);
                for j=1:size(class_errs,1)
                    qidx = trial_labels(tidx)==ul(j);
                    class_errs(j,i,k) = sum(decoded(qidx,i,k)~=ul(j))./sum(qidx);
                end
            catch e
                e
            end
        end
    end
end
