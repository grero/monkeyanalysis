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
	%   					 structure can be specified
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    k = 1;
	types = varargin;
	ntypes = length(types);
    for t=1:length(trials)
		include = 1;
		i = 1;
		while include && (i <= ntypes) 
			if isempty(getfield(trials(t),types{i}))
				include = 0;
			end
			i = i + 1;
		end
		if include == 1
            rtrials(k) = trials(t);
            k = k+1;
		end
    end
end

