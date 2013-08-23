function names = wordsToString(words)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Return the string representation of the 8 bit strobe words
%Input:
%	words		:	matrix where each row represents a single
%					8 bit strobe word
%Output:
%	names		:	the string representation of each strobe
%					word
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	names = {};
	j = 1;
	for i=1:size(words,1)
		w = words(i,:);
		if all(w == zeros(1,8))
			names{j} = 'trial_start';
			j=j+1;
		elseif (w(1) == 1) && (w(1)== 1)
			names{j} = 'session_start';
			j = j+1;
		elseif all(w == [0,0,0,0,0,0,0,1])
			names{j} = 'prestim';
			j=j+1;
		elseif (w(1) == 0) && (w(2) == 1)
			names{j} = 'target';
			j=j+1;
        elseif (w(1) == 1) && (w(2) == 0)
			names{j} = 'distractor';
			j=j+1;
        elseif all(w == [0,0,0,0,0,1,1,0])
			names{j} = 'reward';
			j=j+1;
        elseif all(w == [0,0,0,0,0,1,1,1])
			names{j} = 'failure';
			j=j+1;
        elseif all(w == [0,0,1,0,0,0,0,0])
			names{j} = 'trial_end';
			j=j+1;
	end
end
