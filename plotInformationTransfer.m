function plotInformationTransfer(E11, E112, bins)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Input:
	%	E11			:	entropy of spike train 1 conditioned on own history
	%	E112		:	entropy of spiek train 1 conditioned on both its own history
	%					and the history of spike train 2
	%	bins		:	the bins used to compute the spike count from which the entropies
	%					are computed
	%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	figure
	%get the baseline as before zero
	bidx = bins < 0;
	%get the information transfer at the base line
	Ib = E11(bidx) - E112(bidx);

	h1 = plot(bins,E11-E112);
	%indicate baseline
	hold on
	Ibm = mean(Ib);
	Ibs = std(Ib);
	h2 = plot(bins, repmat(mean(Ib)+3*std(Ib),[length(bins),1]),'r');
	legend(h2, 'Mean + 3\sigma of baseline','Location','NorthWest','Interpreter','latex')
	b = bins(bidx);
	p1 = patch([b(1) b(end) b(end) b(1)], [Ibm-3*Ibs Ibm-3*Ibs Ibm-2*Ibs Ibm-2*Ibs], ...
	[0.5 0.5 0.5 0.5], 'EdgeColor', 'none');
	set(gca,'Box','Off');
	set(gca, 'TickDir','out');
	xlabel('Time [ms]')
	ylabel('Transfer entropy [bits]')
