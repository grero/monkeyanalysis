function rtrials  = getTrialType( trials,type )
%Return a subset of the trials of the specified type. The type should
%correspond to a field in the trial structure e.g. 
%getTrialType(trials,'target') will return all trials in which a
%target appeared. 
%Input:
%   trials          :    trial structure obtained from loadTrialInfo
%   type            :    string indicating which trial type to get.
%                        Possible values are: 'target' and'failure'. 
    k = 1;
    
    for t=1:length(trials)
        if ~isempty(getfield(trials(t),type))
            rtrials(k) = trials(t);
            k = k+1;
        end
    end
end

