function [H,Hc,bins,Hi,Hic] = computePairInformation(counts,bins,trials,shuffle,sort_event,nruns)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute the information contained in the joint counts matrix.
	%Input:
    %	counts		: [2 X ntrials X nbins-1]	:		matrix of spike counts
	%	bins		: [nbins,1]				:		the bins use to compute the spike counts
	%	trials		:		structure array containing information about the trials used
	%	shuffle		:		whether we should also compute shuffle information. Defaults to 0 (no)
	%	sort_event	:		the event used to sort the trials. This defaults to 'target'
    %   nruns       :       number of runs to use when computing shuffle,
    %                       indepdendent information
	%Output:
	%	H			:		Total entropy for each time bin
	%	Hc			:		Conditional entropy for each time bin
	%	bins		:		bins used to compute the spike counts
	%	Hi			:		independent total entropy
	%	Hic			:		independent conditional entropy
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 6
        nruns = 100;
    end
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
		rows(t) = e.row;
		columns(t) = e.column;
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
		[H,Hc,Hi,Hic] = computeEntropies(counts,uc,trial_labels,u,nruns);
	else
		H = zeros(nruns,nbins);
		Hi = zeros(nruns,nbins);
		Hc = zeros(nruns,nbins);
		Hic = zeros(nruns,nbins);
		for k=1:nruns
			tl = randsample(trial_labels,length(trial_labels));
			[H(k,:),Hc(k,:),Hi(k,:),Hic(k,:)] = computeEntropies(counts,uc,tl,u,nruns);
		end
	end

	function [H,Hc,Hi,Hic] = computeEntropies(counts,unique_counts,trial_labels,unique_labels,nruns)
		ncond = length(unique_labels);
		uc = unique_counts;
		mx = length(uc);
		u = unique_labels;
		pC = zeros(ncond,mx,mx); %conditional
		piC = zeros(nruns,ncond,mx,mx); %independent conditional
		p = zeros(mx,mx); %unconditional
		pii = zeros(nruns,mx,mx); %independent unconditional
		H = zeros(nbins,1);
		Hi = zeros(nruns,nbins);
		Hc = zeros(nbins,1);
		Hic = zeros(nruns,nbins);
		for j=1:nbins
            for i=1:ncond
                tidx = trial_labels == u(i);
                c = counts(:,tidx,j);
                for cc1=1:length(uc)
                    for cc2=1:length(uc)
					
						nn = nansum((c(1,:)==uc(cc1))&(c(2,:)==uc(cc2)));
						pC(i,cc1,cc2) = nn;
                    end
                end
                %shuffle the trial indices for one cell
                for l=1:nruns
                    sidx = randsample(1:size(c,2),size(c,2));
                    c2 = c(2,sidx);
                    for cc1=1:length(uc)
                        for cc2=1:length(uc)
                            piC(l,i,cc1,cc2) = nansum((c(1,:)==uc(cc1))&(c2==uc(cc2)));
                        end
                    end
                end
                    

            end
            for cc1=1:length(uc)
                for cc2=1:length(uc)
                    p(cc1,cc2) = nansum((counts(1,:,j)==uc(cc1))&(counts(2,:,j)==uc(cc2)));
                end
            end
            %sidx = randsample(1:size(counts,2),size(counts,2));
            %pii(j,cc1,cc2) = nansum((counts(1,:,j)==uc(cc1))&(counts(2,sidx,j)==uc(cc2)));
				
			%normalize
			pC = pC./repmat(nansum(nansum(pC,2),3),[1,mx, mx]);
			piC = piC./repmat(nansum(nansum(piC,3),4),[1,1,mx, mx]);
			p = p./repmat(nansum(nansum(p,1),2),[mx, mx]);
			%pii(j,:,:) = pii(j,:,:)./repmat(nansum(nansum(pii(j,:,:),2),3),[1, mx, mx]);
            ns = histc(trial_labels,u);
            ps = ns/sum(ns);
            pii(:,:,:) = sum(piC.*repmat(ps',[nruns,1,mx,mx]),2);

			H(j) = -nansum(nansum(p.*log2(p + (p==0)),1),2);
			Hi(:,j) = -nansum(nansum(pii.*log2(pii + (pii==0)),2),3);
			hc = -nansum(nansum(pC.*log2(pC+(pC==0)),2),3);
			hic = -nansum(nansum(piC.*log2(piC+(piC==0)),3),4);
			Hc(j) = (ns/sum(ns))'*hc; 
			Hic(:,j) = (ns/sum(ns))'*hic'; 
		end
	end
end
