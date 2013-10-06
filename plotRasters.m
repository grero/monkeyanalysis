function plotRasters(sptrains,trials,alignment_event,pre_period,post_period)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot rasters for the specified spike trains. The plots
	%are saved under the current directory as gXXcXXsLocationInformation.pdf
	%Input:
	%	sptrains		:		structure array of spike strains
	%	trials			:		structure array of trial information
	%	alignment_event	:		the event to which to align the spike trains
    %   pre_period      :       amount of time to show before the event
    %   pst_perioid     :       amount of time to show after the event
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 5
        post_period = 3000;
    end
    if nargin < 4
        pre_period = 200;
    end
	for ch=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch)).cluster;
		for j=1:length(clusters)
			%create the raster
			[spikes,trial_idx] = createAlignedRaster(clusters(j), trials, alignment_event);
			plotRaster(spikes, trial_idx, trials, alignment_event,pre_period,post_period);

			fname = sprintf('g%.2dc%.2dsTrialRaster.pdf', sptrains.spikechannels(ch),j);
			%save the figure using a tight bounding box, e.g. with no white space around the plot
			saveTightFigure(gcf,fname);
			close
		end
	end
end
