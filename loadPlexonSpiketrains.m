function sptrains = loadPlexonSpiketrains(fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load spike trains from a .txt file produced by the Plexon offline sorter
%Input:
%   fname         :         name of text file containing the sorted spikes.
%                           the file consist of tab-delimited rows where
%                           the first column indicates the channel, the
%                           second column the unit and the third column the
%                           spike time, in seconds.
%Output:
%   sptrains.spikechannels    :    channels with at least one unit
%   sptrains.channels(i).cluster(j).spiketimes   :    the spike times of
%                                                     unit j on channel j,
%                                                     in units of miliseconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    sptrains = struct;
    if ~exist(fname,'file')
        return
    end
    disp(['Loading spikes from file ' fname '...']);
    units = importdata(fname,'\t');
    %we only want channels with sorted units
    channels = unique(units(units(:,2)>0,1));
    sptrains.spikechannels = channels;
    for ch=1:length(channels)
        q = units(units(:,1)==channels(ch),:);
        cids = unique(q(:,2));
        for c=1:length(cids)
            sptrains.channels(channels(ch)).cluster(c).spiketimes = q(q(:,2)==cids(c),3)*1000;
        end
    end
        
end