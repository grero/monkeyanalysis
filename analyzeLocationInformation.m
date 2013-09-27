function analyzeLocationInformation(sptrains,trials,bins,alignment_event,sort_event,doplot,dosave,logfile)
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
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 8
		logfile = 1
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
	k = 1; %to keep track of cells
	fprintf(logfile,'Cell\tOnset\tOffset\n')
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			%check of already existing data
			fname = sprintf('g%.2dc%.2ds%sLocationInformation.mat', sptrains.spikechannels(ch),j,sort_event);
			if exist(fname,'file')
				load(fname);
			else
				%get the counts
				[counts,bins] = getTrialSpikeCounts(clusters(j),trials,bins,'alignment_event',alignment_event);
				[H,Hc,bins,bias] = computeInformation(counts,bins,trials,0,sort_event);
				%shuffle trials to get a null-distribution
				[Hs,Hcs,bins,biass] = computeInformation(counts,bins,trials,1,sort_event);
				%determine significant regions, i.e. regions where I is larger than the 95th percentile of Is
				[onset,offset] = getSignificantInterval(H-Hc,Hs-Hcs,bins);
			end
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
				fname = sprintf('g%.2dc%.2ds%sLocationInformation.mat', sptrains.spikechannels(ch),j,sort_event);
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
	
end
