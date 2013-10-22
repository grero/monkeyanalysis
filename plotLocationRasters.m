function plotLocationRasters(sptrains,trials,alignment_event,regroup,squash_trial_labels)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot rasters for the specified spike trains. The plots
	%are saved under the current directory as gXXcXXsLocationInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	trials			:		structure array of trial information
	%	alignment_event	:		the event to which to align the spike trains
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 5
        squash_trial_labels = 0;
    end
    if nargin < 4
        regroup = 0;
    end
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			%create the raster
			[spikes,trial_idx] = createAlignedRaster(clusters(j), trials, alignment_event);
			plotLocationRaster(spikes, trial_idx, trials, alignment_event,regroup,squash_trial_labels);

			fname = sprintf('g%.2dc%.2dsTrialRaster.pdf', sptrains.spikechannels(ch),j);
			%save the figure using a tight bounding box, e.g. with no white space around the plot
			%saveTightFigure(gcf,fname);
			print('-dpdf',fname,'-loose');
			close
		end
	end
end
