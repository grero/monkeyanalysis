function trials = loadTrialInfo(fname)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Load and parse the event markers contained in the file pointed to by
	%fname
	%Input:
    %   fname		:		name of file containing the marker information. The file should contain two variables;
	%   					sv is the int16 representation of the strobe words and ts is the marker timestamps in seconds
	%Output:
	%	trials		:		struct array with inforamtion about each trial
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if ~exist(fname,'file')
		disp(['File ' fname ' does not exist']);
		return
	end
	load(fname)
	words = strobesToWords(sv);
	trials = struct;
	k = 1;
	for i=1:length(ts)
		w = words(i,:);
		t = ts(i);
		if all(w == zeros(1,8))
			%trials(k) = struct;
			offset = t;
		elseif all(w == [0,0,0,0,0,0,0,1])
			trials(k).prestim = t - offset;
		elseif (w(1) == 0) && (w(2) == 1)
			row = bin2dec(num2str(w(2:5)));
			column = bin2dec(num2str(w(6:end)));
			trials(k).target.timestamp = t - offset;
			trials(k).target.row = row;
			trials(k).target.column = column;
        elseif (w(1) == 1) && (w(2) == 0)
			row = bin2dec(num2str(w(2:5)));
			column = bin2dec(num2str(w(6:end)));
			trials(k).distractors = [trials(k).distractors [t - offset; row; column]];
        elseif all(w == [0,0,0,0,0,1,1,0])
			trials(k).reward = t - offset;
        elseif all(w == [0,0,0,0,0,1,1,1])
			trials(k).failure = t - offset;
        elseif all(w == [0,0,1,0,0,0,0,0])
			k = k + 1;
		end
	end
end
