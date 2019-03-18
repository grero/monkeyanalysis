function qdata = getAlignedLFP(lfpdata, trials, event, t0,t1, alignment_event, trialtype)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Align the single channel data lfpdata to trials using the specified trial-event,
% e.g.
% aligned_lfp = getAlignedLFP(lfpdata, trials, 'target', 100,300,'start');
% to obtain the LFP aligned to target onset, grabbing a window from 100 ms before
% to 300 ms afater target.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin < 7
    trialtype = 'reward';
  end
  if nargin < 6
    alignment_event = 'start';
  end
  ctrials = getTrialType(trials, trialtype);
  aligned_time = getEventTime(ctrials, event, alignment_event);
  tstart = getEventTime(ctrials, 'start', 'start');
  aligned_time = aligned_time + tstart;
  T = 1:length(lfpdata);
  qdata = zeros(t1+t0+1, length(aligned_time));
  size(qdata)
  for i = 1:length(aligned_time)
    idx1 = find(T > aligned_time(i)-t0, 1);
    idx2 = find(T > aligned_time(i)+t1, 1);
    qdata(1:idx2-idx1+1,i) = lfpdata(idx1:idx2);
  end
end
