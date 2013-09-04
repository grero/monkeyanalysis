function [E11,E112,bins] = computeInformationTransfer(sptrains, bins, history, trials, alignment_event,shuffle)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Input:
	%	sptrains	:	cell-array of spike trains to compute information transfer between
	%	bins		:	primary bins, i.e. bins for which we want to predict
	%	history		:	how far back to look from each bin, i.e. if the bin size is 20 ms
	%					and history is specified as 50ms, the 50ms prior to each bin will be
	%					used as the history for that bin
	%	trials		:	structure array containing information about trials
	%	alignment_event	:	event to which to align the spike trains
	%	shuffle			:	whether to compute shuffle information
	%Output:
	%	E11			:	Entropy of the spike counts in spike train 1 conditioned on its
	%					own history
	%	E112		:	Entropy of the spike counts in spike train 1 conditioned on both its
	%					own history ond that of spike train 2.
	%					The difference between these two quantities is the amount of
	%					information transfered from spike train 2 to spike train 1
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	[counts1,b] = getTrialSpikeCounts(sptrains{1},trials,bins,'alignment_event',alignment_event);
	[counts1h,b] = getTrialSpikeCounts(sptrains{1},trials,bins-history,...,
		'alignment_event',alignment_event);
	[counts2h,b] = getTrialSpikeCounts(sptrains{2},trials,bins-history,...,
		'alignment_event',alignment_event);
	
	nbins = length(bins);
	ntrials = size(counts1,1);
	%entropy of spike train 1
	uc = unique(counts1);
	P1 = histc(counts1,uc);
	P1 = P1./repmat(nansum(P1,1),[size(P1,1),1]);
	E1 = -sum(P1.*log2(P1+(P1==0)),1);
	%entropy of spike train 1 conditioned on own history
	uc1 = unique(counts1h);
	uc2 = unique(counts2h);
	P1h = histc(counts1h,uc1);
	P1h = P1h./repmat(sum(P1h,1),[size(P1h,1),1]);
	P2h = histc(counts2h,uc2);
	P2h = P2h./repmat(sum(P2h,1),[size(P2h,1),1]);
	
	if ~shuffle
		%naive way of computing the joint histogram
		Z11 = zeros(nbins,length(uc),length(uc1));
		for i=1:length(uc)
			for j=1:length(uc1)
				Z11(:,i,j) = Z11(:,i,j) + sum((counts1==uc(i))&(counts1h==uc1(j)),1)';
			end
		end
		%normalize
		Z11 = Z11./repmat(nansum(Z11,2),[1,size(Z11,2),1]);
		E11 = -squeeze(sum(Z11.*log2(Z11+(Z11==0)),2));
		E11 = nansum(P1h'.*E11,2);
		%joint counts conditioned on both histories
		Z112 = zeros(nbins,length(uc),length(uc1),length(uc2));
		%joint counts of both histories
		Z12 = zeros(nbins,length(uc1),length(uc2));
		for i=1:length(uc)
			for j=1:length(uc1)
				for k=1:length(uc2)
					Z112(:,i,j) = Z112(:,i,j) + sum((counts1==uc(i))&(counts1h==uc1(j)&(counts2h==uc2(k))),1)';
					Z12(:,j,k) = Z12(:, j,k) + sum((counts1h==uc1(j)&(counts2h==uc2(k))),1)';
				end
			end
		end
		%normalize
		Z112 = Z112./repmat(nansum(Z112,2),[1,size(Z11,2),1,1]);
		Z12 = Z12./repmat(nansum(nansum(Z12,2),3),[1,size(Z12,2),size(Z12,3),1]);

		E112 = -squeeze(nansum(Z112.*log2(Z112+(Z112==0)),2));
		E112 = E112.*Z12;
		E112 = squeeze(nansum(nansum(E112,2),3));
	else
		%naive way of computing the joint histogram
		E11 = zeros(100,nbins);
		E112 = zeros(100,nbins);
		for l=1:100
			%shuffle the trials
			tidx = randsample(1:ntrials,ntrials);
			counts1hs = counts1h(tidx,:);
			counts2hs = counts2h(tidx,:);
			Z11 = zeros(nbins,length(uc),length(uc1));
			for i=1:length(uc)
				for j=1:length(uc1)
					Z11(:,i,j) = Z11(:,i,j) + sum((counts1==uc(i))&(counts1hs==uc1(j)),1)';
				end
			end
			%normalize
			Z11 = Z11./repmat(nansum(Z11,2),[1,size(Z11,2),1]);
			e11 = -squeeze(sum(Z11.*log2(Z11+(Z11==0)),2));
			E11(l,:) = nansum(P1h'.*e11,2);
			%joint counts conditioned on both histories
			Z112 = zeros(nbins,length(uc),length(uc1),length(uc2));
			%joint counts of both histories
			Z12 = zeros(nbins,length(uc1),length(uc2));
			for i=1:length(uc)
				for j=1:length(uc1)
					for k=1:length(uc2)
						Z112(:,i,j) = Z112(:,i,j) + sum((counts1==uc(i))&(counts1hs==uc1(j)&(counts2hs==uc2(k))),1)';
						Z12(:,j,k) = Z12(:, j,k) + sum((counts1hs==uc1(j)&(counts2hs==uc2(k))),1)';
					end
				end
			end
			%normalize
			Z112 = Z112./repmat(nansum(Z112,2),[1,size(Z11,2),1,1]);
			Z12 = Z12./repmat(nansum(nansum(Z12,2),3),[1,size(Z12,2),size(Z12,3),1]);

			e112 = -squeeze(nansum(Z112.*log2(Z112+(Z112==0)),2));
			e112 = e112.*Z12;
			E112(l,:) = squeeze(nansum(nansum(e112,2),3));
		end
	end

	

	


