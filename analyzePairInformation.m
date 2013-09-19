function [Z,Zs,Zi] = analyzePairInformation(sptrains,trials,bins,alignment_event,sort_event,doplot)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Compute and plot the paired information for several spike trains. The plots
	%are saved under the current directory as gXXcXXsJointInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	trials			:		structure array of trial information
	%	bins			:		the bins into which the spike trains should be discretized
	%	alignment_event	:		the event to which to align the spike trains
    %   sort_event      :       the event used to sort the trials
    %   doplot          :       specifies whether to plot (doplot = 1) or
    %                           not (doplot=0). The default is to plot
    %Output:
    %   Z               :       ncells X ncells X nbins matrix of information
    %                           transfer values. The element (i,j,k) of this matrix 
    %                           quantifies how much information encoded jointly 
    %                           by cell j and cell i at time bin k
	%	Zs				:		shuffled version of Z, obtained by shuffling 
	%							trial labels
	%	Zi				:		independent version of Z, obtained by adding the 
	%							information encoded by each cell separately
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 6
        doplot = 1;
    end
    if nargin < 5
        sort_event = 'target';
    end
    %get the number of cells
    ncells = 0;
    for ch1=1:length(sptrains.spikechannels)
        ncells = ncells + length(sptrains.channels(sptrains.spikechannels(ch1)).cluster);
    end
    nbins = length(bins);
    Z = zeros(ncells,ncells,nbins);
    Zs = zeros(ncells,ncells,nbins);
    Zi = zeros(ncells,ncells,nbins);
	Ii = zeros(ncells,nbins); %independent
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
                    dfname = sprintf('g%.2dc%.2dsg%.2dc%.2ds%sJointInformation.mat', sptrains.spikechannels(ch1),j1,...
                            sptrains.spikechannels(ch2),j2,sort_event);
                    %check if we already have the data computed
                    if exist(dfname,'file')
                        load(dfname);
                        Ii(k1,:) = H1-Hc1;
                        Ii(k2,:) = H2-Hc2;
                    else
                   		if all(Z(k2,k1,:) == 0)
							trains = {clusters(j1) clusters2(j2)};
							%get the counts
							[counts,bins] = getJointTrialCounts(trains,trials,bins,'alignment_event',alignment_event);
							%paired information
							[H,Hc,bins,Hi,Hic] = computePairInformation(counts,bins,trials);
							%shuffled pair information
							%[Hs,Hcs,bins] = computePairInformation(counts,bins,trials,1);
							%independent
							if all(Ii(k1,:) == 0)
								[H1,Hc1,bins] = computeInformation(squeeze(counts(1,:,:)),bins,trials);
								Ii(k1,:) = H1-Hc1;
							end
							if all(Ii(k2) == 0)
								[H2,Hc2,bins] = computeInformation(squeeze(counts(2,:,:)),bins,trials);
								Ii(k2,:) = H2-Hc2;
							end
							

							%save results
							disp(['Saving result to file ' dfname '...']);
							save(dfname,'H','Hc','Hi','Hic','H1','Hc1','H2','Hc2','bins');
						else
							load(sprintf('g%.2dc%.2dsg%.2dc%.2ds%sJointInformation.mat', sptrains.spikechannels(ch2),j2,...
									sptrains.spikechannels(ch1),j1,sort_event));

						end
                    end
                    Z(k1,k2,:) = H-Hc;
					Z(k2,k1,:) = Z(k1,k2,:);
                    Zs(k1,k2,:) = mean(Hi-Hic,1) + 3*std(Hi-Hic);
					Zs(k2,k1,:) = Zs(k1,k2,:);
                    Zi(k1,k2,:) = Ii(k1,:) + Ii(k2,:);
					Zi(k2,k1,:) = Zi(k1,k2,:);

                    if doplot
                        plotLocationInformation(squeeze(Z(k1,k2,:)),bins,alignment_event,trials,'I_shuffled',Hi-Hic,'I_ind',squeeze(Zi(k1,k2,:)));
                        fname = sprintf('g%.2dc%.2dsg%.2dc%.2ds%sJointInformation.pdf', sptrains.spikechannels(ch1),j1,...
                            sptrains.spikechannels(ch2),j2,sort_event);
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
