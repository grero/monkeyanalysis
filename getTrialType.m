function rtrials  = getTrialType( trials,varargin )
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Return a subset of the trials of the specified type. The type should
	%correspond to a field in the trial structure e.g. 
	%getTrialType(trials,'target') will return all trials in which a
	%target appeared. 
	%Input:
	%   trials          :    trial structure obtained from loadTrialInfo
	%   varargin        :    strings indicating which trial type to get.
	%   					 any combination of fields found in the trials
	%   					 structure can be specified. To indicate that a field
	%   					 should *not* be present, prefix with '~'. E.g,
	%   					 specifying '~response' will return all trials in which
	%   					 the response cue was *not* given.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    k = 0;
	types = varargin;
	ntypes = length(types);
    for t=1:length(trials)
		include = 1;
		i = 1;
		while include && (i <= ntypes)
            if strfind(types{i},'~') == 1
                if ~isfield(trials(t), types{i}(2:end))
                    include = 1;
                elseif ~isempty(getfield(trials(t),types{i}(2:end)))
                    include = 0;
                end
            else
                if ~isfield(trials(t), types{i})
                    include = 0;
                elseif isempty(getfield(trials(t),types{i}))
                    include = 0;
                end
            end
			i = i + 1;
		end
		if include == 1
            k = k+1;
            rtrials(k) = trials(t);
		end
    end
    if k == 0
        rtrials = [];
    end
end

