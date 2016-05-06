function sessions  = parseEDFData(edfdata,nrows,ncols)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Parse eye link data into a trial structure
    %Input:
    %edfdata    :   eyelink data structure or name of edffile
    %nrows      :   number of grid rwos
    %ncols      :   number of grid columns
    %
	%Output:
	%	trials		:		struct array with information about each trial
    %   trials.start    :    start of the trial, absoute time
    %   trials.prestim  :    start of the prestim-period, relative to trial
    %                        start
    %   trials.target.timestamp    : target onset, relative to trial start
    %   trials.target.row          : row index of the target
    %   trials.target.column       : column index of the target
    %   trials.distractors         : array of distractors; rows are time
    %                                relative to start of the trial, row
    %                                and column index
	%   trial.response			   : time, relative to target onset, of the beginning of the repsonse period
    %   trials.reward              : time of reward, relative trial start
    %   trials.failure             : time of failure, relative to trial
    %                                start
    %   trials.end                 : aboslute time of trial end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ischar(edfdata)
        edfdata = edfmex(edfdata);
    end
    if nargin < 3
        ncols = 5;
        nrows = 5;
    end
    nevents = length(edfdata.FEVENT);
    trialnr = 0;
    sessions = struct;
    sessionnr = 1;
    k = 1;
    for nextevent=1:nevents
        m = edfdata.FEVENT(nextevent).message(1:3:end);
        if ~isempty(m)
            if ((m(1) == '0') && (m(2) == '1')) %target
                %get the row and column index
                if length(m) == 8
                    px = bin2dec(m(5:-1:3));
                    py = bin2dec(m(8:-1:6));
                elseif length(m) == 14
                    px = bin2dec(m(8:-1:3));
                    py = bin2dec(m(end:-1:9));
                end

                sessions(sessionnr).trials(trialnr).target = struct('row', py, 'column', px, 'timestamp', edfdata.FEVENT(nextevent).sttime);

            elseif ((m(1) == '1') && (m(2) == '0'))  %distractor
                if length(m) == 8
                    px = bin2dec(m(5:-1:3));
                    py = bin2dec(m(8:-1:6));
                elseif length(m) == 14
                    px = bin2dec(m(8:-1:3));
                    py = bin2dec(m(end:-1:9));
                end
                sessions(sessionnr).trials(trialnr).distractor = struct('row', py, 'column', px, 'timestamp', edfdata.FEVENT(nextevent).sttime);
            elseif strcmp(m, '00000000') %trial start
                trialnr  = trialnr + 1;
                k = 1;
                trialstart = edfdata.FEVENT(nextevent).sttime;
                sessions(sessionnr).trials(trialnr).start = trialstart;
            elseif strcmp(m,'00000101') %go-cueue
                sessions(sessionnr).trials(trialnr).response_cue = edfdata.FEVENT(nextevent).sttime;
            elseif strcmp(m,'00000110') %reward
                sessions(sessionnr).trials(trialnr).reward = edfdata.FEVENT(nextevent).sttime;
            elseif strcmp(m,'00000111') %failure
                sessions(sessionnr).trials(trialnr).failure = edfdata.FEVENT(nextevent).sttime;
            elseif strcmpi(m,'00000011') %stimulus blank
                sessions(sessionnr).trials(trialnr).stimblank = edfdata.FEVENT(nextevent).sttime;
            elseif strcmpi(m,'00000100') %delay
                sessions(sessionnr).trials(trialnr).delay = edfdata.FEVENT(nextevent).sttime;
            elseif strcmpi(m,'00000001') %fixation start
                sessions(sessionnr).trials(trialnr).fixation_start = edfdata.FEVENT(nextevent).sttime;
            elseif strcmpi(m,'00100000') %trial end
                sessions(sessionnr).trials(trialnr).end = edfdata.FEVENT(nextevent).sttime;
	    elseif strcmpi(m, '11000000') %session start
		    sessionnr = sessionnr + 1;
		    sessions(sessionnr).trials = struct;
		    trialnr = 0; %reset the trial counter
            end
        else
            if strcmpi(edfdata.FEVENT(nextevent).codestring, 'ENDSACC')
                %check that event immediately before this was cue onset, i.e. we want to grap the first saccade after cue
                m = edfdata.FEVENT(nextevent-3).message(1:3:end);
                if strcmp(m,'00000101') %go-cueue
                    event = edfdata.FEVENT(nextevent);
                    sessions(sessionnr).trials(trialnr).saccade = struct('startx', event.gstx, 'starty', event.gsty, 'endx', event.genx', 'endy', event.geny, 'start_time', event.sttime, 'end_time', event.entime);
                end
            end
        end %if ~isempty(m)
    end
end
