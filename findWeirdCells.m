function cidx = findWeirdCells(Z)
	dd = diff(Z,1,2);
	m = mean(dd,2);
	s = std(dd,0,2);
	%find points for which values jump by more than 5 std of the mean difference
	[cidx,idx] = find(abs(dd-repmat(m,[1,size(dd,2)])) > 5*repmat(s,[1,size(dd,2)]));
	cidx = unique(cidx)
end
