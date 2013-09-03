function [spikes,trial_idx] = createAlignedRaster(sptrain,trials,alignment_event)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Align spike train to trial start
%Input:
%	sptrain     	:   flat vector with spiketimes in miliseconds
%   trials      	:    trial structure obtained from loadTrialInfo
%	alignment_event	:	event to which to align the spike trains. The event
%Output:
%   spikes      	:       spike time shifted to aligned with the start of
%                           each trial
%   trial_idx   	:       index of the trial to which each spike belongs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin == 2
		alignment_event = 'prestim';
	end
	if ~isfield(trials,alignment_event)
		alignment_event = 'prestim';
	end
	%get the row and column of each trial so that we can sort the trials according to location
	row = zeros(length(trials),1);
	column = zeros(length(trials),1);
    for t=1:length(trials)
        row(t) = trials(t).target.row;
        column(t) = trials(t).target.column;
	end
	ncols = max(column);
	trial_label = (row-1)*ncols + column;
	[s,sidx] = sort(trial_label);
    spikes = [];
    trial_idx = [];
    spiketimes = sptrain.spiketimes;
    for ti=1:length(sidx)
		t = sidx(ti);
        if ~isempty(trials(t).start) && ~isempty(trials(t).end)
            idx = (spiketimes >= (trials(t).start*1000))&(spiketimes<=(trials(t).end*1000));
            alignto = getfield(trials(t),alignment_event);
            if isstruct(alignto)
                alignto = alignto.timestamp;
            end
            spikes = [spikes (spiketimes(idx)'-trials(t).start*1000 - alignto*1000)];
            trial_idx = [trial_idx ti*ones(1,sum(idx))];
        end
    end
   
end
