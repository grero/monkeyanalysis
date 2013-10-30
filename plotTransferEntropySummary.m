function plotTransferEntropySummary(fname,zmax,zmin)
    if nargin < 3
        zmin = nan;
    end
    if nargin < 2
        zmax = nan;
    end
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
    
    figure
    [mx,mxi] = max(sig_cnx,[],1);
    [s,idx] = sort(mxi);
    if isnan(zmax)
        zmax = max(sig_cnx(:));
    end
    if isnan(zmin)
        zmin = min(sig_cnx(:));
    end
    imagesc(bins(1:size(sig_cnx,1)), 1:length(idx), sig_cnx(:,idx)',[zmin,zmax])
	c = colorbar
	set(get(c,'ylabel'),'string','Z-score')
	print('-dpng','all_sig_cnx.png')
    
    %all
    figure
    %sort by connection
    %within channels 1-32
    idxg = zeros(length(processed_combos),2);
    cnx_labels = {'1-32', '33-64', '65-96','97-128', '1-32 -> 33-64', '33-64 -> 1-32', ...
        '1-32 -> 65-96', '65-96 -> 1-32', '1-32 -> 97-128', '97-128 -> 1-32',...
        '32-64 -> 65-96', '65-96 -> 32-64', '32-64 -> 97-128', '97-128 \\-> 32-64',...
        '65-96 -> 97-128', '97-128 \\-> 65-96'};
    for i=1:length(processed_combos)
        groups = sscanf(processed_combos{i},'g%dc%*dsg%dc%*ds');
        if all(ismember(groups,1:32))
            idxg(i,1) = 1;
            idxg(i,2) = 1;
        elseif all(ismember(groups,33:64))
            idxg(i,1) = 2;
            idxg(i,2) = 2;
        elseif all(ismember(groups,65:96))
            idxg(i,1) = 3;
            idxg(i,2) = 3;
        elseif all(ismember(groups,97:128))
            idxg(i,1) = 4;
            idxg(i,2) = 4;
        elseif ismember(groups(1), 1:32) && ismember(groups(2),33:64)
            idxg(i,1) = 5;
            idxg(i,2) = 6;
         elseif ismember(groups(2), 1:32) && ismember(groups(1),33:64)
            idxg(i,2) = 5;
            idxg(i,1) = 6;
        elseif ismember(groups(1),1:32) && ismember(groups(2), 65:96)
            idxg(i,1) = 7;
            idxg(i,2) = 8;
        elseif ismember(groups(2),1:32) && ismember(groups(1), 65:96)
            idxg(i,2) = 7;
            idxg(i,1) = 8;
        elseif ismember(groups(1), 1:32) && ismember(groups(2), 97:128)
            idxg(i,1) = 9;
            idxg(i,2) = 10; 
        elseif ismember(groups(2), 1:32) && ismember(groups(1), 97:128)
            idxg(i,1) = 9;
            idxg(i,2) = 10;
        elseif ismember(groups(1), 32:64) && ismember(groups(2), 65:96)
            idxg(i,1) = 11;
            idxg(i,2) = 12;
        elseif ismember(groups(2), 32:64) && ismember(groups(1), 65:96)
            idxg(i,2) = 11;
            idxg(i,1) = 12;
        elseif ismember(groups(1), 32:64) && ismember(groups(2), 97:128)
            idxg(i,1) = 13;
            idxg(i,2) = 14;
        elseif ismember(groups(2), 32:64) && ismember(groups(1), 97:128)
            idxg(i,2) = 13;
            idxg(i,1) = 14;
        elseif ismember(groups(1), 65:96) && ismember(groups(2), 97:128)
            idxg(i,1) = 15;
            idxg(i,2) = 16;
        elseif ismember(groups(2), 65:96) && ismember(groups(1), 97:128)
            idxg(i,2) = 15;
            idxg(i,1) = 16;
        end
    end
    idxg = idxg';
    idxg = idxg(:);
    [mx,mxi] = max(all_cnx,[],1);
    vidx = find(diff(sort(idxg))>0);
    
    %sort by connection type, then by connection strength
    [bx,bidx] = sortrows([idxg mxi']);
    [s,idx] = sort(mxi);
    if isnan(zmax)
        zmax = max(all_cnx(:));
    end
    if isnan(zmin)
        zmin = min(all_cnx(:));
    end
    
    imagesc(bins(1:size(all_cnx,1)), 1:length(bidx), all_cnx(:,bidx)',[zmin,zmax])
    hold on
    plot(repmat([bins(1) bins(end)],size(idx,1),1), [vidx vidx],'k')
	c = colorbar
	set(get(c,'ylabel'),'string','Z-score')
	print('-dpng','all_cnx.png')
    figure
    ucats = unique(idxg);
    ncats = length(ucats);
    for k=1:ncats
        subplot(ncats,1,k);
        acnx = all_cnx(:,idxg==ucats(k));
        [mx,mxi] = max(acnx,[],1);
        [s,idx] = sort(mxi);
        acnx = acnx(:,idx);
        imagesc(bins(1:size(all_cnx,1)), 1:sum(idxg==ucats(k)), acnx',[zmin,zmax])
        set(gca,'YTickLabel',[]);
        if k ~= ncats
            set(gca,'XTickLabel',[]);
        end
        ylabel(cnx_labels(ucats(k)));
    end
    print('-dpng','all_area_cnx.png')
end
