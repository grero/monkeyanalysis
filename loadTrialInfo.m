function trials = loadTrialInfo(fname)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Load and parse the event markers contained in the file pointed to by
	%fname
	%Input:
    %   fname		:		name of file containing the marker information. The file should contain two variables;
	%   					sv is the int16 representation of the strobe words and ts is the marker timestamps in seconds
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
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if ~exist(fname,'file')
		disp(['File ' fname ' does not exist']);
		return
    end
    T = load(fname);
    sv = T.sv;
    ts = T.ts;
	words = strobesToWords(sv);
	trials = struct;
	k = 0;
	offset = 0;
        i = 1;
        while i <= length(ts)
		w = words(i,:);
		t = ts(i);
		if all(w == zeros(1,8))
            k = k + 1;
			offset = t;
			trials(k).start = t;
        elseif k >= 1
            if all(w == [0,0,0,0,0,0,0,1])
                trials(k).prestim = t - offset;
            elseif (w(1) == 0) && (w(2) == 1)
                if i < size(words,1) && words(i+1,1) == 0 && words(i+1,2) == 1
                    column = bin2dec(num2str(w(8:-1:3)));
                    row = bin2dec(num2str(words(i+1,8:-1:3)))
                    i = i +1;
                else
                    column = bin2dec(num2str(w(5:-1:3)));
                    row = bin2dec(num2str(w(end:-1:6)));
                end

                trials(k).target.timestamp = t - offset;
                trials(k).target.row = row;
                trials(k).target.column = column;
            elseif (w(1) == 1) && (w(2) == 0)

                if i < size(words,1) && words(i+1,1) == 1 && words(i+1,2) == 0
                    column = bin2dec(num2str(w(8:-1:3)));
                    row = bin2dec(num2str(words(i+1,8:-1:3)));
                    i = i +1;
                else
                    column = bin2dec(num2str(w(5:-1:3)));
                    row = bin2dec(num2str(w(end:-1:6)));
                end
                if ~isfield(trials(k),'distractors')
                    trials(k).distractors = [];
                end
                trials(k).distractors = [trials(k).distractors [t - offset; row; column]];

            elseif all(w == [0,0,0,0,0,1,0,0])
                trials(k).delay = t-offset;
            elseif all(w == [0,0,0,0,0,1,0,1])
                trials(k).response = t-offset;
            elseif all(w == [0,0,0,0,0,1,1,0])
                trials(k).reward = t - offset;
            elseif all(w == [0,0,0,0,0,1,1,1])
                trials(k).failure = t - offset;
            elseif all(w == [0,0,1,0,0,0,0,0])
                trials(k).end = t;
            end
        end
        i = i + 1;
	end
end
