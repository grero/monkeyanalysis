function analyzeTransferEntropy(sptrains,trials)
	k = 1;
	k1 = 1;
	k2 = 1;
	for ch1=1:length(sptrains.spikechannels)
		clusters = sptrains.channels(sptrains.spikechannels(ch1)).cluster;
		for j1=1:length(clusters)
            k2 = 1;
			cell1 = sprintf('g%dc%.2ds', sptrains.spikechannels(ch1), j1);
			for ch2=1:length(sptrains.spikechannels)
				clusters2 = sptrains.channels(sptrains.spikechannels(ch2)).cluster;
                for j2=1:length(clusters2)
                    %skip if both clusters are the same
                    if (ch1 == ch2) && (j1==j2)
                        k2 = k2 + 1; %make sure we still increae the counter
                        continue
                    end
					cell2 = sprintf('g%dc%.2ds', sptrains.spikechannels(ch2), j2);
					fname = [cell1 cell2 'transferEntropy.pdf'];
					if ~exist(fname)
						plotTransferEntropy(cell1,cell2,trials);
					end
					close
					k2 = k2 + 1;
					k = k+1;
				end
			end
			k = k + 1;
		end
	end
end
