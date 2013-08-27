function plotLocationInformation(I,bins,alignment_event,trials)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot raster for different target locations
	%Input:
	%	I		 		:	[nbins,1] Information encoded about the target locationo
	%						per bin
	%	bins			:	the bins used to compute the spike counts
	%	alignment_event	:	the event to which the spike counts were 
	%						aligned
	%	trials			:	structure array of trials information
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	response = zeros(length(trials),1);
	for t=1:length(trials)
		response(t) = trials(t).response;
		alignto = getfield(trials(t),alignment_event);
		if isstruct(alignto)
			alignto = alignto.timestamp;
		end
		response(t) = (response(t)-alignto)*1000;
	end
	R = nanmedian(response);
	Rv = prctile(response(~isnan(response)),[25,75]);
    rl = Rv(1);
    rh = Rv(2);
	figure
	plot(bins,I)
	yl = ylim;
	hold on
	h1 = plot([R,R], [yl(1),yl(2)],'r','linewidth',2);
	h2 = plot([rl,rl], [yl(1),yl(2)],'r');
	h3 = plot([rh,rh], [yl(1),yl(2)],'r');
	legend(h1,'Median response period onset','Location','NorthWest');
	%prettify plot
	set(gca,'Box','Off');
	set(gca, 'TickDir','out');
	xlabel('Time [ms]')
	ylabel('Information [bits]')
