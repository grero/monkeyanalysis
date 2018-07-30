function plotDecoder(cerr,row,col,bins,performance,fig)
    if nargin < 6
        performance = nan;
    end
	rowcol = unique([row col],'rows');
	rows = rowcol(:,1);
	columns = rowcol(:,2) ;
	%sort according to column, since that's how the trial_labels are generated
	nrows = max(rows);
	ncols = max(columns);
	idx = (columns-1)*nrows + rows;
	[s,sidx] = sort(idx);
	rows = rows(sidx);
	columns = columns(sidx);
	%fig2 = figure
	if nargin < 6
		fig = figure
	else
		axesf = get(fig,'Children');
	end
    dh = 0.9/nrows;
    dv = 0.9/ncols;
    ncats = nrows*ncols;
	for q=1:size(cerr,1)
		row = rows(q);
		column = columns(q);
		%ax = subplot(5,5,qu(q));
		%column order
		if ~exist('axesf','var')
			ax = subplot('Position',[0.1 + (column-1)*dv,0.99-(row*dh), 0.85*dv, 0.85*dh]);
			shadedErrorBar(bins,squeeze(nanmean(1-cerr(q,:,:),3)), squeeze(nanstd(1-cerr(q,:,:),0,3)));
		else
			ii = (column-1)*nrows + row;
			axes(axesf(length(axesf)-q+1)); %reverse
			ax = gca;
			hold on;
			shadedErrorBar(bins,squeeze(nanmean(1-cerr(q,:,:),3)), squeeze(nanstd(1-cerr(q,:,:),0,3)),'b',1);
		end
		xlim([bins(1),bins(end)])
		hold on
		plot([0 0], [0 1.0], 'k');
		if (row ~= nrows) || (column ~= 1)
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
