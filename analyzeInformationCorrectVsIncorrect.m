function [dI,dI_shuffled]  = analyzeInformationCorrectVsIncorrect(sptrains,correct_trials,incorrect_trials,bins,alignment_event,sort_event,doplot,dosave,logfile)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute and plot the information for several spike trains. The plots
	%are saved under the current directory as gXXcXXsLocationInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	correct_trials	:		structure array of correct trial information
	%	incorrect_trials:		structure array of incorrect trial information
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
	allonsets = [];
	alloffsets = [];
	cellidx = [];
    nbins = length(bins);
	k = 1; %to keep track of cells
    dI = zeros(sptrains.ntrains,nbins);
    dI_shuffled = zeros(sptrains.ntrains, 100,nbins);
	fprintf(logfile,'Cell\tOnset\tOffset\n');
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			%check of already existing data
			fname = sprintf('g%dc%.2ds%sInformationCorrectVsIncorrect.mat', sptrains.spikechannels(ch),j,sort_event);
			if exist(fname,'file')
				load(fname);
			else
				[I_c,I_ic,I_cs,I_ics] = compareInformation(clusters(j),-200:50:3000,correct_trials,incorrect_trials);
				%determine significant regions, i.e. regions where I is larger than the 95th percentile of Is
				[onsets,offsets] = getSignificantInterval(mean(I_c,1)'-mean(I_ic,1)',I_cs-I_ics,bins);
            end
            if exist('I_correct','var')
                I_c = I_correct;
                I_ic = I_incorrect;
                if ~exist('onsets','var')
                    [onsets,offsets] = getSignificantInterval(mean(I_c)-mean(I_ic)',I_cs-I_ics,bins);
                end
            end
            if ~exist('I_cs','var')
                if doplot
                    figure
                    h = shadedErrorBar(squeeze(bins(1:size(I_c,1))),squeeze(mean(I_c,2)),squeeze(2*std(I_c,0,2)),'b');
                    hold on
                    h2 = shadedErrorBar(squeeze(bins(1:size(I_ic,1))),squeeze(mean(I_ic,2)),squeeze(2*std(I_ic,0,2)),'r');
                    fname = sprintf('g%dc%.2ds%sInformationCorrectVsIncorrect.pdf', sptrains.spikechannels(ch),j,sort_event);
                    print(gcf,'-dpdf',fname);
                end
            else
            
                dI(k,:) = mean(I_c,2) - mean(I_ic,2);
                dI_shuffled(k,:,:) = I_cs - I_ics;
                 if doplot
                    fname = sprintf('g%dc%.2ds%sInformationCorrectVsIncorrect.pdf', sptrains.spikechannels(ch),j,sort_event);
                    print(gcf,'-dpdf',fname);
                    close
                 end
            end
            allonsets = [allonsets;onsets];
            alloffsets = [alloffsets;offsets];
            cellidx = [cellidx; k*ones(length(onsets),1)];
               
			if dosave
				fname = sprintf('g%dc%.2ds%sInformationCorrectVsIncorrect.mat', sptrains.spikechannels(ch),j,sort_event);
				if ~exist(fname,'file')
					save(fname,'I_c','I_ic','I_ics','I_cs','bins','onset','offset');
				end
			end
			if ~isnan(onsets)
				fprintf(logfile,'g%dc%.2ds\t%f\t%f\n', sptrains.spikechannels(ch),j,onsets,offsets);
			else
				%fprintf(1,'g%dc%.2ds\t-\t-', sptrain.spikechannels(ch);
			end

			k = k + 1;
		end
	end
	%print out a table of
	fprintf(logfile,'Number of cells with at least one significant interval: %d\n', length(unique(cellidx(~isnan(onsets)))));
	fprintf(logfile,'Median onset: %f\n', nanmedian(allonsets));
	fprintf(logfile,'Median offset: %f\n', nanmedian(alloffsets));
	fprintf(logfile,'Median interval length: %f\n', nanmedian(alloffsets-allonsets));
	if logfile ~= 1
		fclose(logfile);
	end
	%create a summary plot
    %only plot the significant points
    Ic = nan*zeros(size(dI));
    Ic(dI > squeeze(prctile(dI_shuffled,95,2))) = dI(dI > squeeze(prctile(dI_shuffled,95,2)));
    Ic(dI < squeeze(prctile(dI_shuffled,5,2))) = dI(dI < squeeze(prctile(dI_shuffled,5,2)));
    h = imagesc(bins,1:size(Ic,1),Ic);
    set(h,'AlphaData',~isnan(Ic))
    xlabel('Time [ms]')
    ylabel('Cell number');
    c = colorbar;
    set(get(c,'YLabel'),'String','Information');
    %indicate zero
    hold on
    plot([0 0], [1 size(Ic,1)], 'k');
    cc = cumsum(sptrains.unitsperchannel);
    %get the limit between fef and dlpfc
    db = mean(diff(bins));
    idx_dlpfc = cc(find(sptrains.spikechannels <= 64,1,'last'))-0.5;
    plot([bins(1) bins(end)] -0.5*db, [idx_dlpfc idx_dlpfc], 'k');
    
    idx_fef = cc(find(sptrains.spikechannels <= 32,1,'last'))-0.5;
    plot([bins(1) bins(end)]-0.5*db, [idx_fef idx_fef], 'k');
    
    idx_vdlpfc = cc(find(sptrains.spikechannels <= 96,1,'last')) - 0.5;
    plot([bins(1) bins(end)] -0.5*db, [idx_vdlpfc idx_vdlpfc], 'k');
end
