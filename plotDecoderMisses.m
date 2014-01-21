function plotDecoderMisses(decoded, actual, row,col,nrows,ncols)
	rowcol = unique([row col],'rows');
	rows = rowcol(:,1);
	columns = rowcol(:,2) ;
	if nargin < 5
		nrows = max(rows);
	end
	if nargin < 6
		ncols = max(columns);
	end
	fig = figure
    dh = 0.9/nrows;
    dv = 0.9/ncols;
    ncats = nrows*ncols;
	qu = unique(actual);
	%qu = 1:ncats;
	mxper = 0;
	for q=1:length(qu)
	%for q=1:ncats
		row = rows(q);
		column = columns(q);
		%ax = subplot(5,5,qu(q));
		%column order
		%(column-1)*nrows + row
		%idx = actual(:) == (row-1)*ncols + column;
		idx = actual(:) == (column-1)*nrows + row;
		if sum(idx) == 0
			continue
		end
		n = zeros(length(qu),1);
		for i=1:size(decoded,2)
			s = decoded(:,i,:);
			nn = histc(s(idx),qu);
			qq = ~isnan(nn);
			n(qq) = n(qq) + nn(qq);
		end
		n = n/nansum(n);
		E = -n'*log2(n + (n==0));
		ax = subplot('Position',[0.1 + (column-1)*dv,0.99-(row*dh), 0.85*dv, 0.85*dh]);
		qidx = qu==(column-1)*nrows + row;
		bar(qu(~qidx),n(~qidx),'b')
		hold all
		bar(qu(qidx),n(qidx),'r')
		mxper = max(mxper,max(n));
		if (row ~= nrows) || (column ~= 1)
			set(ax,'XTickLabel',[]);
			set(ax,'YTickLabel',[]);
		else
			xlabel('Position')
			set(gca,'XTicklabel',qu)
		end
		set(ax,'Box','off');
		set(ax,'TickDir','out');
		title(['Entropy = ' num2str(E)])
    end
	c = get(fig,'Children');
	for ci=1:length(c)
		set(c(ci),'YLim',[0 mxper]);
	end
    
end
