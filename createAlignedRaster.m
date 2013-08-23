function [spikes,trial_idx] = createAlignedRaster(sptrain,trials)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Align spike train to trial start
%Input:
%       sptrain     :       flat vector with spiketimes in miliseconds
%       trials      :       trial structure obtained from loadTrialInfo
%Output:
%       spikes      :       spike time shifted to aligned with the start of
%                           each trial
%       trial_idx   :       index of the trial to which each spike belongs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    spikes = [];
    trial_idx = [];
    spiketimes = sptrain.spiketimes;
    for t=1:length(trials)
        if ~isempty(trials(t).start) && ~isempty(trials(t).end)
            idx = (spiketimes >= (trials(t).start*1000))&(spiketimes<=(trials(t).end*1000));
            spikes = [spikes (spiketimes(idx)'-trials(t).start*1000)];
            trial_idx = [trial_idx t*ones(1,sum(idx))];
        end
    end
   
end