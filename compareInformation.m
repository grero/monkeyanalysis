function [I_correct, I_incorrect, I_correct_shuffled, I_incorrect_shuffled] = compareInformation(sptrain,bins,correct_trials,incorrect_trials,save)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Compare information encoded about target in correct and incorrect
    %trials
    %Input:
    %   sptrain         :       the spike train to analyze
    %   bins            :       the bins in which to compute spike counts
    %   correct_trials  :       structure containing information about
    %                           correct trials
    %   incrreoct_trials:       structure containing information about
    %                           incorrect trials
    %   save            :       whether to save the computed data
    %Output:
    %   I_correct        :      information in correct trials
    %   I_incorrect      :      information in incorrect trials
    %   I_correct_shuffled:     information when randomly permuting correct
    %   I_incorrect_shuffled:   /incorrect tials
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
    if nargin < 5
        save = 0;
    end
    nbins = length(bins);
	I_correct = zeros(100,nbins);
	I_incorrect = zeros(100,nbins);
    I_correct_shuffled = zeros(100,nbins);
	I_incorrect_shuffled = zeros(100,nbins);
	for i=1:100
		[ctrials,qtrials] = equalizeTrials(correct_trials,incorrect_trials);
		counts_c = getTrialSpikeCounts(sptrain,ctrials,bins,'alignment_event','target');
		counts_ic = getTrialSpikeCounts(sptrain,qtrials,bins,'alignment_event','target');
		[H,Hc] = computeInformation(counts_c, bins,ctrials,0,'target');
		I_correct(i,:) = H-Hc;
		[H,Hc] = computeInformation(counts_ic, bins, qtrials,0,'target');
		I_incorrect(i,:) = H-Hc;
        %permutation
		atrials = [ctrials,qtrials];
        idx = randsample(1:length(atrials),size(counts_c,1),true);
		sctrials = atrials(idx);
        idx = randsample(1:length(atrials),size(counts_ic,1),true);
		sqtrials = atrials(idx);
        [H,Hc] = computeInformation(counts_c, bins,sctrials,0,'target');
		I_correct_shuffled(i,:) = H-Hc;
		[H,Hc] = computeInformation(counts_ic, bins, sqtrials,0,'target');
		I_incorrect_shuffled(i,:) = H-Hc;
    end
    if save
        
    end
    %figure
    %shadedErrorBar(bins,mean(I_correct),2*std(I_correct),'b');
    %hold on
    %shadedErrorBar(bins,mean(I_incorrect),2*std(I_incorrect),'r');

    figure
    H = shadedErrorBar(bins,mean(I_correct_shuffled-I_incorrect_shuffled),...
        2*std(I_correct_shuffled-I_incorrect_shuffled),'r');
    h1 = H.mainLine;
    hold on
    h2 = plot(bins,mean(I_correct -I_incorrect,1),'b')
    xlabel('Time [ms')
    ylabel('$I_{\rm correct} - I_{\rm incorrect}$','interpreter','latex')
    legend([h1 h2], 'Permuted difference','Actual difference');
    %prettify plot
	set(gca,'Box','Off');
	set(gca, 'TickDir','out');
end
