function plotRaster(spikes,trial_idx,trials,alignment_event,prePeriod,postPeriod)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot raster with trials arranged according to location
	%Input:
	%	spikes		:		timestamps of spikes to be plotted, in
	%						units of ms
	%	trial_idx	:		the trial index of spike
	%	trials		:		structure array containing information about the 
	%						trials used to aligned the spikes
	%	alignment_event:	the event used to align the spikes, .e.g. 'target'
	%	prePeriod		:	period before the event
	%	postPeriod		:	period after the event
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 6
		postPeriod = 200;
	end
	if nargin < 5
		prePeriod = 200;
	end
	%get the distribution of response period onsets
	response = zeros(length(trials),1);
	for t=1:length(trials)
		
		alignto = getfield(trials(t),alignment_event);
		if isstruct(alignto)
			alignto = alignto.timestamp;
        end
        if isfield(trials,'response')
            if ~isempty(trials(t).response)
                response(t) = trials(t).response;
                response(t) = (response(t)-alignto)*1000;
            end
        end
	end
	R = nanmedian(response);
	Rv = prctile(response(~isnan(response)),[25,75]);
    rl = Rv(1);
    rh = Rv(2);
	figure
	%show spikes that are at least 200 ms before trigger and at most 
	%3000 ms after the trigger
	sidx = (spikes > -prePeriod)&(spikes < postPeriod);
	plot(spikes(sidx),trial_idx(sidx),'.');
	set(gca,'Box','Off');
	set(gca,'TickDir','out');
	xlabel('Time [ms]');
	ylabel('Trial')

	yl = ylim;
	%indicate zero
	hold on
	plot([0 0],[yl(1), yl(2)],'k');
    if prePeriod >= R
        h1 = plot([R,R], [yl(1),yl(2)],'r','linewidth',2);
        h2 = plot([rl,rl], [yl(1),yl(2)],'r');
        h3 = plot([rh,rh], [yl(1),yl(2)],'r');
        legend(h1,'Median response period onset','Location','SouthWest');
    end
end

