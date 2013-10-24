function [onsets_f,offsets_f, onsets_b,offsets_b, comboidx_f, comboidx_b] = analyzeTransferEntropy(sptrains,trials,logfile,minnbins)
	if nargin < 4
        minnbins = 5;
    end
    if nargin < 3
		logfile = 1;
	elseif ischar(logfile)
		logfile = fopen(logfile,'w')
	end
	k = 1;
	k1 = 1;
	k2 = 1;
    onsets_f = [];
    offsets_f = [];
    onsets_b = [];
    offsets_b = [];
    comboidx_f = [];
    comboidx_b  = [];
	fef_dlpfc_lat = [];
	dlpfc_fef_lat = [];
    fef_dlpfc_cnx = [];
    dlpfc_fef_cnx = [];
    processed_combos = {};
    ntrains = sptrains.ntrains;
    ncombos = ntrains*(ntrains-1)/2;
    sig_cnx = [];
    fprintf(1,'Analyzing %d combinations...\n' ,ncombos);
    %progress = ['|','/','-','\'];
	for ch1=1:length(sptrains.spikechannels)
        spch1 = sptrains.spikechannels(ch1);
		clusters = sptrains.channels(sptrains.spikechannels(ch1)).cluster;
		for j1=1:length(clusters)
            k2 = 1;
			cell1 = sprintf('g%dc%.2ds', sptrains.spikechannels(ch1), j1);
			for ch2=1:length(sptrains.spikechannels)
				clusters2 = sptrains.channels(sptrains.spikechannels(ch2)).cluster;
                spch2 = sptrains.spikechannels(ch2);
                for j2=1:length(clusters2)
                    
                    cell2 = sprintf('g%dc%.2ds', sptrains.spikechannels(ch2), j2);
                    combo = [cell1 cell2];
                    %skip if both clusters are the same
                    if (ch1 == ch2) && (j1==j2)
                        k2 = k2 + 1; %make sure we still increae the counter
                        continue
                    elseif (ismember(combo,processed_combos)) || (ismember([cell2 cell1], processed_combos))
                        k2 = k2 + 1;
                        continue
                    end
					
                    %if logfile ~= 1
                    %    fprintf(1,'\b
                    %end
					fname = [cell1 cell2 'transferEntropy.pdf'];
					if ~exist(fname)
						[onset_f,offset_f,onset_b,offset_b,z1,z2] = plotTransferEntropy(cell1,cell2,trials,1,1,minnbins);
					else
						[onset_f,offset_f,onset_b,offset_b,z1,z2] = plotTransferEntropy(cell1,cell2,trials,0,1,minnbins);
                    end
                    
                    if sum(~isnan(onset_f)) > 0
                        fprintf(logfile, '%s%s\t', cell1,cell2);
                        fprintf(logfile, '%f ', [onset_f offset_f]');
                        fprintf(logfile,'\n');
                        sig_cnx = [sig_cnx z1];
						if (ismember(spch1, 32:64))&&(ismember(spch2, 65:96))
							fef_dlpfc_lat = [fef_dlpfc_lat onset_f'];
                            fef_dlpfc_cnx = [fef_dlpfc_cnx z1];
						elseif (ismember(spch2, 32:64))&&(ismember(spch1, 65:96))
							dlpfc_fef_lat = [dlpfc_fef_lat onset_f'];
                            dlpfc_fef_cnx = [dlpfc_fef_cnx z1];
						end
                    end
                    if sum(~isnan(onset_b)) > 0
                        fprintf(logfile, '%s%s\t', cell2,cell1);
                        fprintf(logfile, '%f ', [onset_b offset_b]');
                        fprintf(logfile,'\n');
                        sig_cnx = [sig_cnx z2];
						if (ismember(spch2, 32:64))&&(ismember(spch1, 65:96))
							fef_dlpfc_lat = [fef_dlpfc_lat onset_b'];
                            fef_dlpfc_cnx = [fef_dlpfc_cnx z2];
						elseif (ismember(spch1, 32:64))&&(ismember(spch2, 65:96))
							dlpfc_fef_lat = [dlpfc_fef_lat onset_b'];
                            dlpfc_fef_cnx = [dlpfc_fef_cnx z2];
						end
                    end
					onsets_f = [onsets_f onset_f'];
					offsets_f = [offsets_f offset_f'];
					onsets_b = [onsets_b onset_b'];
					offsets_b = [offsets_b offset_b'];
					comboidx_f = [comboidx_f k*ones(1,length(onset_f))];
					comboidx_b = [comboidx_b k*ones(1,length(onset_b))];    
					k2 = k2 + 1;
                    %fprintf(1,'\b%s', progress(
                    fprintf(1,[repmat('\b',[1,length(num2str(k-1))]) '%d'],k);
					k = k+1;
                    processed_combos = [processed_combos combo];
                    close
				end
			end
			k1 = k1 + 1;
		end
    end
    fprintf('\n');
	cell1 = sprintf('g%dc%.2ds', sptrains.spikechannels(1), 1);
	cell2 = sprintf('g%dc%.2ds', sptrains.spikechannels(2), 1);
    fname = [cell1 cell2 'transferEntropy.mat'];
    if ~exist(fname,'file')
        fname = [cell2 cell1 'transferEntropy.mat'];
    end
    load(fname);
    %summary
	npairs_f = length(unique(comboidx_f(~isnan(onsets_f))));
	npairs_b = length(unique(comboidx_b(~isnan(onsets_b))));
    fprintf(logfile,'Number of pairs with at least 1 significant interval %d\n', npairs_f + npairs_b);
	fprintf(logfile, 'Number of dlpfc -> fef connections: %d\n', length(dlpfc_fef_lat));
	fprintf(logfile, '\t Median connection onset %f\n', nanmedian(dlpfc_fef_lat));
	fprintf(logfile, 'Number of fef -> dlpfc connections: %d\n', length(fef_dlpfc_lat));
	fprintf(logfile, '\t Median connection onset %f\n', nanmedian(fef_dlpfc_lat));

    save('summary.mat','onsets_f','offsets_f','onsets_b','offsets_b','comboidx_f','comboidx_b','fef_dlpfc_lat','dlpfc_fef_lat','fef_dlpfc_cnx','dlpfc_fef_cnx','bins',...
        'sig_cnx');
	if logfile ~= 1
		fclose(logfile);
    end
    plotTransferEntropySummary('summary.mat')
end
