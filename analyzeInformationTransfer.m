function analyzeInformationTransfer(sptrains,trials,bins,history, alignment_event)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute and plot the information for several spike trains. The plots
	%are saved under the current directory as gXXcXXsLocationInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	trials			:		structure array of trial information
	%	bins			:		the bins into which the spike trains should be discretized
	%	alignment_event	:		the event to which to align the spike trains
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	for ch1=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch1)).cluster;
		for j1=1:length(clusters)
			for ch2=1:length(sptrains.spikechannels)
				clusters2 = sptrains.channels(sptrains.spikechannels(ch2)).cluster;
                for j2=1:length(clusters2)
                    %skip if both clusters are the same
                    if (ch1 == ch2) && (j1==j2)
                        continue
                    end
                    trains = {clusters(j1) clusters2(j2)};
                    %get the counts
                    [E11,E112,bins] = computeInformationTransfer(trains,bins,history, trials,alignment_event,0);
                    plotInformationTransfer(E11,E112,bins);
                    fname = sprintf('g%.2dc%.2dsg%.2dc%.2dsInformationTransfer.pdf', sptrains.spikechannels(ch1),j1,...
                        sptrains.spikechannels(ch2),j2);
                    print('-dpdf',fname);
               end
			end
		end
	end
end
