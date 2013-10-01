function plotLocationInformation(I,bins,alignment_event,trials,varargin)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Plot raster for different target locations
	%Input:
	%	I		 		:	[nbins,1] Information encoded about the target locationo
	%						per bin
	%	bins			:	the bins used to compute the spike counts
	%	alignment_event	:	the event to which the spike counts were 
	%						aligned
	%	trials			:	structure array of trials information
	%	I_shuffled		:	[optional] shuffle information obtained by shuffle trial labels
	%	I_ind			:	[optional] independent information, e.g. sum of information from 
	%						two cells
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Args = struct('I_shuffled',[],'I_ind',[]);
	[Args,varargin] = getOptArgs(varargin, Args);
	Is = Args.I_shuffled;
	Iind = Args.I_ind;
	figure
	hold on
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
	if ~isempty(Is)
        M = mean(Is,1);
        S = std(Is,1);
		
        if exist('shadedErrorBar')
            H = shadedErrorBar(bins,M,2*S);
            h4 = H.mainLine;
        else
            %plot the lower bound as mean + 3 std devations of the shuffled
            %information
            h4 = plot(bins,M+2*S,'g');
        end
	end
	if ~isempty(Iind)
        if  isvector(Iind)
            h5 = plot(bins, Iind,'m');
        elseif exist('shadedErrorBar')
            H2 = shadedErrorBar(bins,mean(Iind,1),2*std(Iind,1),'r');
            h5 = H2.mainLine;
        end
    end
    hold on
    plot(bins,I)
	yl = ylim;
	h1 = plot([R,R], [yl(1),yl(2)],'r','linewidth',2);
	h2 = plot([rl,rl], [yl(1),yl(2)],'r');
	h3 = plot([rh,rh], [yl(1),yl(2)],'r');
	plot([0,0],[yl(1),yl(2)],'k');
	if ~isempty(Is) && ~isempty(Iind)
		legend([h1,h4,h5],'Median response period onset','Shuffle info [mean + 3td]','Independent','Location','SouthWest');
	elseif ~isempty(Is) 
		legend([h1,h4],'Median response period onset','Shuffle info [mean + 3td]','Location','SouthWest');
	elseif ~isempty(Iind) 
		legend([h1,h5],'Median response period onset','Independent','Location','SouthWest');
	else
		legend(h1,'Median response period onset','Location','SouthWest');
	end
	%prettify plot
	set(gca,'Box','Off');
	set(gca, 'TickDir','out');
	xlabel('Time [ms]')
	ylabel('Information [bits]')
