function response = getEventTime(trials, event, alignment_event)
  if ~isfield(trials,event)
      disp('Invalid event')
      return
  end
  if nargin < 3
      alignment_event = 'target';
  end
  if ~isfield(trials,alignment_event)
      disp('Invalid alignment event')
      return
  end
  response = nan*zeros(length(trials),1);
  for t=1:length(trials)
      r = getfield(trials(t),event);
      if isempty(r)
          continue;
      end
      if isstruct(r)
          response(t) = r.timestamp;
      elseif strcmpi(event,'distractors')
          response(t) = r(1);
      else
          response(t) = r;
      end
  if ~strcmpi(event,'start')
    alignto = getfield(trials(t),alignment_event);
    if isstruct(alignto)
      alignto = alignto.timestamp;
    end
  else
    alignto = 0;
      end
      if strcmpi(alignment_event,'start')
          alignto = 0;
      end
      response(t) = (response(t)-alignto)*1000;
  end
  response = response(isnan(response)==0);
end
