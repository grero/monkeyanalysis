function A = generateNAStructure(sptrains,trials,alignment_event,window)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Generate an iput structure that can be used with the Neuro-Analysis toolkit
	%Input:
	%	sptrains	:	structure of spike trains
	%	trials		:	structure of trial information
	%	alignment_event	:	the trial event to which spikes should be aligned.
	%						Defaults to 'target'
	%Output:
	%	I			:	Input structure that can be used with
	%					the NeuroAnalysis toolkit
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%make sure we have a valid alignment
	if nargin < 3
		alignment_event = 'target';
	elseif ~isfield(trials,alignment_event)
		alignment_event = 'target';
	end
	if nargin < 4
		window = [-200,2600];
	end

	%get the row and column of each trial so that we can sort the trials according to location
	row = zeros(length(trials),1);
	column = zeros(length(trials),1);
    for t=1:length(trials)
        row(t) = trials(t).target.row;
        column(t) = trials(t).target.column;
	end

	nrows = max(row);
	trial_labels = (column-1)*nrows + row;

	A = struct;
	A.M = int32(length(unique(trial_labels)))
	%get a population raster
	[spikes,trialidx,cellidx] = getPopulationRaster(sptrains,trials,window);
	ncells = length(unique(cellidx));
	A.N = int32(ncells);
	for ch=1:A.N
		A.sites(ch).label = {['ch' num2str(ch)]};
		A.sites(ch).recording_tag = {'episodic'};
		A.sites(ch).time_scale = 0.001; %we use units of miliseconds
		A.sites(ch).time_resolution = 1/40.0; %40 kHz sampling rate
		A.sites(ch).si_unit = 'V';
		A.sites(ch).si_prefix = 10^-3;
	end
	ulabels = unique(trial_labels);
	for i=1:length(ulabels)
		A.categories(i).label = {['location' num2str(ulabels(i))]};
		tidx = find(trial_labels == ulabels(i));
		A.categories(i).P = int32(length(tidx));
		A.categories(i).trials = [];
		for t=1:length(tidx)
			te = getfield(trials(tidx(t)),alignment_event);
            if isstruct(te)
                tt = te.timestamp;
            else
                tt = te;
            end
            tt = tt*1000;
			start_time = tt+window(1);
			end_time = tt + window(2);
			for c=1:ncells
				qidx = (cellidx == c) & (trialidx == tidx(t));
				A.categories(i).trials(t,c).Q = int32(sum(qidx));
				A.categories(i).trials(t,c).list = sort(spikes(qidx));
                A.categories(i).trials(t,c).start_time = start_time;
                A.categories(i).trials(t,c).end_time = end_time;
			end
		end
	end
end


