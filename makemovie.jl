module MakeMovie
import Information
using MATLAB


function movie(session::String)
	#get the trials
	trials = Information.loadTrialInfo("/Users/roger/Dropbox/Data/Pancake/20130923/event_data.mat")
	rtrials = Information.getTrialType(trials,:reward) #get the rewarded trials
	trial_labels = Information.getTrialLocationLabel(trials;transpose=true)
	goodidx = find((trial_labels[int(trialidx)].==D2["I"][:,2])&(trial_labels[int(trialidx)].==D2["I"][:,end]))
	goodidx = goodidx[sortperm(sum(D2["I"][goodidx].==trial_labels[trialidx][goodidx],2))]

end

movie(goodidx::Array{Int64,1}) = movie(float(goodidx))

function movie(goodidx::Array{Float64,1})

	#preparation
	eval_string("idxr = [];")
	eval_string("idxs = [];")
	eval_string("for i=1:length(edfdata.FEVENT)
       if strcmpi(edfdata.FEVENT(i).message(1:3:end),'00000000')
           idxr = [idxr i];
	   elseif strcmpi(edfdata.FEVENT(i).message(1:3:end),'00000001')
			idxs = [idxs i];
       end
     end")
	@mput goodidx
	i = 1
	eval_string("tt1 = find(edfdata.FSAMPLE.time==edfdata.FEVENT(idxr(decoded.test_orig(goodidx($(i))))).sttime)")
	eval_string("tt2 = find(edfdata.FSAMPLE.time==edfdata.FEVENT(idxr(double(decoded.test_orig(goodidx($(i))))+1)).sttime)")
	@matlab M = replayExperiment(tt1(1),(tt2(1)-tt1(1))/50,edfdata,50,decoded)
	@matlab close("all")
	for i=2:length(goodidx)
       eval_string("tt1 = find(edfdata.FSAMPLE.time==edfdata.FEVENT(idxr(decoded.test_orig(goodidx($(i))))).sttime)")
       eval_string("tt2 = find(edfdata.FSAMPLE.time==edfdata.FEVENT(idxr(double(decoded.test_orig(goodidx($(i))))+1)).sttime)")
       @matlab M = replayExperiment(tt1(1),(tt2(1)-tt1(1))/50,edfdata,50,decoded,M)
       @matlab close("all")
   end
   @matlab M = close(M);
end

end #module

