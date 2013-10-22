function plotTransferEntropySummary(fname)
	load(fname);
	figure
	[mx,mxi] = max(dlpfc_fef_cnx,[],1);
	[s,idx] = sort(mxi);
	imagesc(bins(1:size(dlpfc_fef_cnx,1)), 1:length(idx), dlpfc_fef_cnx(:,idx)')
	c = colorbar
	set(get(c,'ylabel'),'string','Z-score')
	print('-dpng','dlpfc_fef_cnx.png')

	figure
	[mx,mxi] = max(fef_dlpfc_cnx,[],1);
	[s,idx] = sort(mxi);
	imagesc(bins(1:size(fef_dlpfc_cnx,1)), 1:length(idx), fef_dlpfc_cnx(:,idx)')
	c = colorbar
	set(get(c,'ylabel'),'string','Z-score')
	print('-dpng','fef_dlpfc_cnx.png')
end
