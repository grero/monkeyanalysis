function Z = analyzeInformationTransfer(sptrains,trials,bins,history, alignment_event,doplot)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute and plot the information for several spike trains. The plots
	%are saved under the current directory as gXXcXXsLocationInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	trials			:		structure array of trial information
	%	bins			:		the bins into which the spike trains should be discretized
	%	alignment_event	:		the event to which to align the spike trains
    %   doplot          :       specifies whether to plot (doplot = 1) or
    %                           not (doplot=0). The default is to plot
    %Output:
    %   Z               :       ncells X ncells X nbins matrix of information
    %                           transfer values. The element (i,j,k) of this matrix 
    %                           quantifies how much information is
    %                           tranferred from cell j to cell i at time
    %                           bin k
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 6
        doplot = 1;
    end
    %get the number of cells
    ncells = 0;
    for ch1=1:length(sptrains.spikechannels)
        ncells = ncells + length(sptrains.channels(sptrains.spikechannels(ch1)).cluster);
    end
    nbins = length(bins);
    Z = zeros(ncells,ncells,nbins);
    k1 = 1; %keeps track of cells
	for ch1=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch1)).cluster;
		for j1=1:length(clusters)
            k2 = 1;
			for ch2=1:length(sptrains.spikechannels)
				clusters2 = sptrains.channels(sptrains.spikechannels(ch2)).cluster;
                for j2=1:length(clusters2)
                    %skip if both clusters are the same
                    if (ch1 == ch2) && (j1==j2)
                        k2 = k2 + 1; %make sure we still increaes the counter
                        continue
                        
                    end
                    trains = {clusters(j1) clusters2(j2)};
                    %get the counts
                    [E11,E112,bins] = computeInformationTransfer(trains,bins,history, trials,alignment_event,0);
                    Z(k1,k2,:) = E11-E112;
                    if doplot
                        plotInformationTransfer(E11,E112,bins,trials);
                        fname = sprintf('g%.2dc%.2dsg%.2dc%.2dsInformationTransfer.pdf', sptrains.spikechannels(ch1),j1,...
                            sptrains.spikechannels(ch2),j2);
                        print('-dpdf',fname);
                        close
                    end
                    k2 = k2 + 1;
                end
                
            end
            k1 = k1 + 1;
        end
        
	end
end
