function [I,I_shuffled]  = analyzeLocationInformation(sptrains,trials,bins,alignment_event,sort_event,doplot,dosave,logfile,regroup)
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
	k = 1; %to keep track of cells
    I = zeros(sptrains.ntrains,nbins);
    I_shuffled = zeros(sptrains.ntrains, 100,nbins);
	fprintf(logfile,'Cell\tOnset\tOffset\n');
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
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
				[onset,offset] = getSignificantInterval(H-Hc,Hs-Hcs,bins);
			end
			I(k,1:length(bins)) = H-Hc;
			I_shuffled(k,:,1:length(bins)) = Hs-Hcs;
			onsets = [onsets;onset];
			offsets = [offsets;offset];
			cellidx = [cellidx; k*ones(length(onset),1)];
			if doplot
				plotLocationInformation(H-Hc-bias,bins,alignment_event,trials,'I_shuffled',Hs-Hcs-biass)
				fname = sprintf('g%.2dc%.2ds%sLocationInformation.pdf', sptrains.spikechannels(ch),j,sort_event);
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
	%create a summary plot
    %only plot the significant points
    figure
    Ic = nan*zeros(size(I));
    Ic(I > squeeze(prctile(I_shuffled,95,2))) = I(I > squeeze(prctile(I_shuffled,95,2)));
    h = imagesc(bins,1:size(I,1),Ic);
    set(h,'AlphaData',~isnan(Ic))
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
    %save
    print('-dpdf','summary.pdf');
end
