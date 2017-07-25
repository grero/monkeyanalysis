function [spikes, trialidx] = create_spike_raster(sptrain, alignto, tmin, tmax)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Create a spike raster by aligning each spike in sptrain to the
    %timepoints in alignto, keeping spikes that are within alignto - tmin
    %and alignto + tmax
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ntrials = length(alignto);
    spikes  = [];
    trialidx = [];
    for i=1:ntrials
        t0 = alignto(i);
        idx = (sptrain > (t0+tmin))&(sptrain < (t0 + tmax));
        spikes = [spikes;sptrain(idx)-t0];
        trialidx = [trialidx;repmat(i, sum(idx),1)];
    end
end
