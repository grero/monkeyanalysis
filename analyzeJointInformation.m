function [Z,Zs,Zi,onsets,offsets] = analyzeJointInformation(sptrains,trials,bins,alignment_event,sort_event,doplot,dosave,group1,group2,logfile,skip)
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
    %                            not (doplot=0). The default is to plot
    %   group1          :       the first group of cells
    %   group2          :       the second group of cells
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
    if nargin < 10
        skip = 0;
    end
    if nargin < 9
        logfile = 1;
    end
    if nargin < 8
        group1 = sptrains.spikechannels;
    else
        %make sure we are using valid channels
        group1 = intersect(group1,sptrains.spikechannels);
    end
    if nargin < 9
        group2 = sptrains.spikechannels;
    else
        %make sure we are using valid channels
        group2 = intersect(group2,sptrains.spikechannels);
    end
    if nargin < 7
        dosave = 1;
    end
    if nargin < 6
        doplot = 1;
    end
    if nargin < 5
        sort_event = 'target';
    end
    if ischar(logfile)
        logfile = fopen(logfile,'w');
    end
    %get the number of cells
    ncells = 0;
    ncells1 = 0;
    ncells2 = 0;
    ncombos = 0;
    %report the number of comparison before starting the loop
    ncells1 = sum(sptrains.unitsperchannel(ismember(sptrains.spikechannels,group1)));
    if all(group1==group2)
        ncells2 = ncells1;
        ncombos = nchoosek(ncells1,2)-ncells1;
    else
        ncells2 = sum(sptrains.unitsperchannel(ismember(sptrains.spikechannels,group2)));
        ncombos = ncells1*ncells2;
    end
    fprintf(logfile,'Computing %d combinations...\n', ncombos);
    
    nbins = length(bins);
    Z = zeros(ncells1,ncells2,nbins);
    Zs = zeros(ncells1,ncells2,nbins);
    Zi = zeros(ncells1,ncells2,nbins);
	Ii = zeros(ncells1+ncells2,nbins); %independent
    k1 = 1; %keeps track of cells
    onsets = [];
    offsets = [];
    comboidx = [];
    k = 1;
	for ch1=1:length(group1)
		clusters = sptrains.channels(group1(ch1)).cluster;
		for j1=1:length(clusters)
            k2 = 1;
			
			for ch2=1:length(group2)
				clusters2 = sptrains.channels(group2(ch2)).cluster;
                for j2=1:length(clusters2)
                    %skip if both clusters are the same
                    if (ch1 == ch2) && (j1==j2)
                        k2 = k2 + 1; %make sure we still increaes the counter
                        k = k + 1;
                        continue
                        
                    end
                    dfname = sprintf('g%.2dc%.2dsg%.2dc%.2ds%sJointInformation.mat', sptrains.spikechannels(ch1),j1,...
                            sptrains.spikechannels(ch2),j2,sort_event);
                    %check if we already have the data computed
                    trains = {clusters(j1) clusters2(j2)};
                    if exist(dfname,'file')
                        load(dfname);
                        Ii(k1,:) = H1-Hc1;
                        Ii(k2,:) = H2-Hc2;
                        if exist('Hs','var')
                            if all((mean(Hs-Hcs,1))'>H-Hc)
                                fprintf(1,'Recomputing shuffled..\n');
                                clear Hs Hcs
                            end
                        end
                        if ~exist('Hs','var')
                            if ~exist('counts','var')
                                [counts,bins] = getJointTrialCounts(trains,trials,bins,'alignment_event',alignment_event);
                                counts = permute(counts,[2,3,1]);
                            end
                            [Hs,Hcs,bins] = computeJointInformation(counts,bins,trials,1,alignment_event);
                        end
                    elseif skip
                        k = k + 1;
                        continue;
                    else
                   		if all(Z(k2,k1,:) == 0)
							
							%get the counts
							[counts,bins] = getJointTrialCounts(trains,trials,bins,'alignment_event',alignment_event);
							counts = permute(counts,[2,3,1]);
                            %paired information
							[H,Hc,bins,bias,Hi,Hic] = computeJointInformation(counts,bins,trials,0,alignment_event);
							%shuffled pair information
							[Hs,Hcs,bins] = computeJointInformation(counts,bins,trials,1,alignment_event);
							%independent
							
                            [H1,Hc1,bins] = computeInformation(squeeze(counts(:,:,1)),bins,trials);
                            Ii(k1,:) = H1-Hc1;
                            [H2,Hc2,bins] = computeInformation(squeeze(counts(:,:,2)),bins,trials);
                            Ii(k2,:) = H2-Hc2;
                            
							%save results
							
                           
                        
						end
                    end
                    if dosave
                        disp(['Saving result to file ' dfname '...']);
                        save(dfname,'H','Hc','Hi','Hic','Hs','Hcs','H1','Hc1','H2','Hc2','bins','counts');
                    end
                    [onset,offset] = getSignificantInterval(H-Hc,Hs-Hcs,bins);
                    if ~isnan(onset)
                        fprintf(logfile,'g%.2dc%.2dsg%.2dc%.2ds\t%f\t%f\n', sptrains.spikechannels(ch2),j2,...
									sptrains.spikechannels(ch1),j1,onset,offset);
                    end
                    comboidx = [comboidx; k*ones(length(onset),1)];
                    onsets = [onsets;onset];
                    offsets = [offsets;offset];
                    
                    Z(k1,k2,:) = H-Hc;
					Z(k2,k1,:) = Z(k1,k2,:);
                    Zs(k1,k2,:) = mean(Hi-Hic,1) + 3*std(Hi-Hic);
					Zs(k2,k1,:) = Zs(k1,k2,:);
                    Zi(k1,k2,:) = Ii(k1,:) + Ii(k2,:);
					Zi(k2,k1,:) = Zi(k1,k2,:);

                    if doplot
                        plotLocationInformation(squeeze(Z(k1,k2,:)),bins,alignment_event,trials,'I_shuffled',Hs-Hcs,'I_ind',Hi-Hic);
                        fname = sprintf('g%.2dc%.2dsg%.2dc%.2ds%sJointInformation.pdf', sptrains.spikechannels(ch1),j1,...
                            sptrains.spikechannels(ch2),j2,sort_event);
                        print('-dpdf',fname);
                        close
                    end
                    k2 = k2 + 1;
                    k = k+1;
                end
                
            end
            k1 = k1 + 1;
        end
        
    end
    %print out a table of
	fprintf(logfile,'Number of combos with at least one significant interval: %d\n', length(unique(comboidx(~isnan(onsets)))));
	fprintf(logfile,'Median onset: %f\n', nanmedian(onsets));
	fprintf(logfile,'Median offset: %f\n', nanmedian(offsets));
	fprintf(logfile,'Median interval length: %f\n', nanmedian(offsets-onsets));
    if logfile > 1
        fclose(logfile)
    end
end
