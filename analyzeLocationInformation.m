function [I,I_shuffled]  = analyzeLocationInformation(sptrains,trials,bins,alignment_event,sort_event,doplot,dosave,logfile,regroup,minnbins)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute and plot the information for several spike trains. The plots
	%are saved under the current directory as gXXcXXsLocationInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	trials			:		structure array of trial information
	%	bins			:		the bins into which the spike trains should be discretized
	%	alignment_event	:		the event to which to align the spike trains. Defaults 
	%							to target
	%	sort_event		:		the event used to sort the trials. Defaults
	%							to 'target'
	%	doplot			:		indicate whether to plot results for ecah cell
	%	dosave			:		indicate whether the computed values should be saved
	%	logfile			:		log file to write the result to, defaults to 1, i.e. 
	%							standard out. Both a file name and a file handle can
	%							be specified
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 10
		minnbins = 3;
	end
    if nargin < 9
        regroup = 0;
    end
	if nargin < 8
		logfile = 1;
	end
	if nargin < 7
		dosave = 1;
	end
	if nargin <  6
		doplot = 1;
	end
	if nargin < 5
		sort_event = 'target';
	end
	if nargin < 4
		alignment_event = 'target';
	end
	if ischar(logfile)
		logfile = fopen(logfile,'w');
	end
	onsets = [];
	offsets = [];
	cellidx = [];
    nbins = length(bins);
	cells = {};
	k = 1; %to keep track of cells
    I = zeros(sptrains.ntrains,nbins);
    I_shuffled = zeros(sptrains.ntrains, 100,nbins);
	fprintf(logfile,'Cell\tOnset\tOffset\n');
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			cells{k} = sprintf('g%dc%.2ds',sptrains.spikechannels(ch),j);
			%check of already existing data
			fname = sprintf('g%dc%.2ds%sInformation.mat', sptrains.spikechannels(ch),j,sort_event);
			if exist(fname,'file')
				load(fname);
			else
				%get the counts
				[counts,bins] = getTrialSpikeCounts(clusters(j),trials,bins,'alignment_event',alignment_event);
				[H,Hc,bins,bias] = computeInformation(counts,bins,trials,0,sort_event,regroup);
				%shuffle trials to get a null-distribution
				[Hs,Hcs,bins,biass] = computeInformation(counts,bins,trials,1,sort_event,regroup);
				%determine significant regions, i.e. regions where I is larger than the 95th percentile of Is
				
            end
            [onset,offset] = getSignificantInterval(H-Hc,Hs-Hcs,bins,97.5,minnbins);
			I(k,1:length(H)) = H-Hc;
			I_shuffled(k,:,1:length(H)) = Hs-Hcs;
			onsets = [onsets;onset];
			offsets = [offsets;offset];
			cellidx = [cellidx; k*ones(length(onset),1)];
			if doplot
                if exist('bias','var')
                    plotLocationInformation(H-Hc-reshape(bias(1:length(H)),size(H)),bins,alignment_event,trials,'I_shuffled',Hs-Hcs-biass(:,1:size(Hcs,2)))
                else
                    plotLocationInformation(H-Hc,bins,alignment_event,trials,'I_shuffled',Hs-Hcs)
                end
				fname = sprintf('g%dc%.2ds%sInformation.pdf', sptrains.spikechannels(ch),j,sort_event);
				print('-dpdf',fname);
				close
			end
			if dosave
				fname = sprintf('g%dc%.2ds%sInformation.mat', sptrains.spikechannels(ch),j,sort_event);
				if ~exist(fname,'file')
					save(fname,'H','Hc','Hs','Hcs','bins','bias','biass','onset','offset');
				end
			end
			if ~isnan(onset)
				fprintf(logfile,'g%dc%.2ds\t%f\t%f\n', sptrains.spikechannels(ch),j,onset,offset);
			else
				%fprintf(1,'g%dc%.2ds\t-\t-', sptrain.spikechannels(ch);
			end

			k = k + 1;
		end
	end
	%print out a table of
	fprintf(logfile,'Number of cells with at least one significant interval: %d\n', length(unique(cellidx(~isnan(onsets)))));
	fprintf(logfile,'Median onset: %f\n', nanmedian(onsets));
	fprintf(logfile,'Median offset: %f\n', nanmedian(offsets));
	fprintf(logfile,'Median interval length: %f\n', nanmedian(offsets-onsets));
	if logfile ~= 1
		fclose(logfile);
	end
	%save data
	fprintf(1,'Saving data to %s\n', 'summary.mat');
	save('summary.mat', 'onsets','offsets','cellidx','cells','bins','I','I_shuffled');
	%create a summary plot
    %only plot the significant points
	response = nan*zeros(length(trials),1);
    distractor = nan*zeros(length(trials),1);
	for t=1:length(trials)
        
		alignto = getfield(trials(t),alignment_event);
		if isstruct(alignto)
			alignto = alignto.timestamp;
        end
        if isfield(trials(t),'saccade')
            response(t) = trials(t).saccade.timestamp;
            response(t) = (response(t)-alignto)*1000;
        elseif ~isempty(trials(t).response)
            response(t) = trials(t).response;
            response(t) = (response(t)-alignto)*1000;
        end
        if isfield(trials(t),'distractors')
            distractor(t) = (trials(t).distractors(1)-alignto)*1000;
        end
	end
    figure
    Ic = nan*zeros(size(I));
    Ic(I > squeeze(prctile(I_shuffled,95,2))) = I(I > squeeze(prctile(I_shuffled,95,2)));
    Z = (I-squeeze(mean(I_shuffled,2)))./squeeze(std(I_shuffled,0,2));
    %h = imagesc(bins,1:size(I,1),Ic);
    %plot z-score instead
    h = imagesc(bins,1:size(I,1),Z);

    %set(h,'AlphaData',~isnan(Ic))
    xlabel('Time [ms]')
    ylabel('Cell number');
    c = colorbar;
    set(get(c,'YLabel'),'String','Information');
    %indicate zero
    hold on
    plot([0 0], [1 size(I,1)], 'k');
    cc = cumsum(sptrains.unitsperchannel);
    %get the limit between fef and dlpfc
    db = mean(diff(bins));
    idx_fef = cc(find(sptrains.spikechannels <= 32,1,'last'))-0.5;
    plot([bins(1) bins(end)]-0.5*db, [idx_fef idx_fef], 'k');
    
    idx_dlpfc = cc(find(sptrains.spikechannels <= 64,1,'last'))-0.5;
    plot([bins(1) bins(end)] -0.5*db, [idx_dlpfc idx_dlpfc], 'k');
    
    idx_vdlpfc = cc(find(sptrains.spikechannels <= 96,1,'last')) - 0.5;
    plot([bins(1) bins(end)] -0.5*db, [idx_vdlpfc idx_vdlpfc], 'k');
	yl = ylim
	%indicate distracot onset, if any
	if sum(~isnan(distractor)) >0
		mmd = nanmedian(distractor);
		h10 = plot([mmd,mmd], [yl(1),yl(2)],'g');
	end
	Rm = nanmedian(response)
    h8 = plot([Rm,Rm], [yl(1),yl(2)],'r');
    %save
    set(gca,'TickDir','out')
    print('-depsc','summary.eps');
end
