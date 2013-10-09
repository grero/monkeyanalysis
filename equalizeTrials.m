function [ctrials_m,ictrials_m] = equalizeTrials(ctrials,ictrials)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%equalize the number of trials per location for the two supplied
	%trial structures by subsampling the trial structure with the largest 
	%number of trials for each locaiton
	%Output:
	%	ctrials_m	:	equalized version of ctrials
	%	ictrials_m	:	equalized version of ictrials
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
    ctrial_labels = getTrialLocationLabel(ctrials);
    ictrial_labels = getTrialLocationLabel(ictrials);
    %2. equalize the number of trials by sub-sampling
    ul = union(unique(ctrial_labels),unique(ictrial_labels));
    s1 = histc(ctrial_labels,ul);
    s2 = histc(ictrial_labels,ul);

    ctrials_m = [];
    ictrials_m = [];
    for k=1:length(ul)
        if s2(k) < s1(k)
            idx = randsample(find(ctrial_labels==ul(k)),s2(k));
            ctrials_m = [ctrials_m ctrials(idx)];
            ictrials_m = [ictrials_m ictrials(ictrial_labels==ul(k))];
        elseif s1(k) < s2(k)
            idx = randsample(find(ictrial_labels==ul(k)),s1(k));
            ictrials_m = [ictrials_m ictrials(idx)];
            ctrials_m = [ctrials_m ctrials(ctrial_labels==ul(k))];
        end
    end
    

end
