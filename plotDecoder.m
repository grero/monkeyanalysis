function plotDecoder(cerr,trial_labels,bins,nrows,ncols,performance,fig)
    if nargin < 6
        performance = nan;
    end
    if nargin < 5
        ncols = 5;
    end
    if nargin < 4
        nrows = 5;
    end
    qu = unique(trial_labels);
	if nargin < 7
		fig = figure
	else
		axesf = get(fig,'Children');
	end
    dh = 0.9/nrows;
    dv = 0.9/ncols;
    ncats = nrows*ncols;
    for q=1:length(qu)
        %ax = subplot(5,5,qu(q));
        %column order
        column = (floor((qu(q)-1)/nrows));
        row = qu(q) - column*nrows;
        column = column + 1;
		if ~exist('axesf','var')
			ax = subplot('Position',[0.1 + (row-1)*dv,0.99-(column*dh), 0.85*dv, 0.85*dh]);
			shadedErrorBar(bins,squeeze(nanmean(1-cerr(q,:,:),3)), squeeze(nanstd(1-cerr(q,:,:),0,3)));
		else
			ii = (column-1)*nrows + row;
			axes(axesf(length(qu)-q+1));
			ax = gca;
			hold on;
			shadedErrorBar(bins,squeeze(nanmean(1-cerr(q,:,:),3)), squeeze(nanstd(1-cerr(q,:,:),0,3)),'b',1);
		end
        xlim([bins(1),bins(end)])
        hold on
        plot([0 0], [0 1.0], 'k');
        if (row ~= ncols) || (row ~= 1)
            set(ax,'XTickLabel',[]);
            set(ax,'YTickLabel',[]);

        else
            xlabel('Time [ms]')
            ylabel('P(correct) ');
        end
        set(ax,'Box','off');
        set(ax,'TickDir','out');
        ylim([0,1.0])
        %indicate chance
        plot([bins(1) bins(end)],[1/ncats 1/ncats],'k--')
        %check if we are given the animals performance
        if any(~isnan(performance))
            plot([bins(1) bins(end)], [performance(qu(q)), performance(qu(q))],'r--');
        end
    end
    %TODO: 
    
end
