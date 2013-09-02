function [counts, bins] = getTrialSpikeCounts(sptrain,trials,bins, varargin)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Get the spike count for the supplied spike train in the given bins
	%Input:
	%	sptrain				:		array of spike times, in ms
	%	trials				:		structure array containing trial information
	%	bins				:		the bins (in ms) in which to compute spike counts
	%	alignment_event		:		event to which to align the spike trains. The event
	%								must be a field in the trials structure array,
	%								e.g. 'response' or 'target'. If the event is not 
	%								a member of trials, it default to 'prestim', i.e. 
	%								start of fixation
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Args = struct('alignment_event','prestim','overlap',0);
	[Args,varargin] = getOptArgs(varargin, Args);
 	alignment_event = Args.alignment_event;
	if ~isfield(trials, alignment_event)
		alignment_event = 'prestim';
	end
	overlap = Args.overlap;
	ntrials = length(trials);
	counts = zeros(ntrials,length(bins));
	trial_idx = [];
    spiketimes = sptrain.spiketimes;
    for t=1:ntrials
        if ~isempty(trials(t).start) && ~isempty(trials(t).end)
            idx = (spiketimes >= (trials(t).start*1000))&(spiketimes<=(trials(t).end*1000));
            alignto = getfield(trials(t),alignment_event);
            if isstruct(alignto)
                alignto = alignto.timestamp;
            end
            spikes = (spiketimes(idx)'-trials(t).start*1000 - alignto*1000);
			c = histc(spikes,bins);
			counts(t,:) = c;
        end
    end
   
end
