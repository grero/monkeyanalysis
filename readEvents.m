function [words,ts] = readEvents(fname)

    %get the available channels
    pl2 = PL2GetFileIndex(fname);
    samplingRate = pl2.TimestampFrequency;
    %get the index of the WB channels
	WBChannels = [];
	for i=1:length(pl2.AnalogChannels)
		if strcmpi(pl2.AnalogChannels{i}.SourceName,'WB')
			WBChannels = [WBChannels i];
		end
	end
	fprintf(1,'Reading events\n');
	k = 1;
	T = [];
	I = [];
	for ch=17:32 %these are the 8 single event channels used
		events = PL2EventTS(fname,ch);
		%to align events to the continuous recording, subtract the initial delay from the events
		%check if we have more than one fragment
		%this is hackish; to get the frag time stamp, re-read one channel
		ad = PL2Ad(fname,WBChannels(1));
		if size(ad.FragTs,1)>1
			ts = events.Ts;
			offset = 0;
			for i=1:size(ad.FragTs,1)
				%figure out the difference between the actual start of the fragment
				%and the start assuming continuous recording, i.e. what the events assume
				%offset keeps track of continuous time
				dt = ad.FragTs(i)-offset;
				ts(ts>=offset)  = ts(ts>=offset)-dt;
				offset = ad.FragCounts(i)/samplingRate;
			end
		else
			ts = events.Ts - ad.FragTs;
		end
		sv = events.Strobed;
		T = [T;ts];
		I = [I;k*sv];
		k = k+1;
	end
	[s,sidx] = sort(T); %sort to get the proper order of event time stamps
	TO = T(sidx);
	IO = I(sidx);
	words = zeros(1,16);
	t0 = TO(1);
	row = 1;
	for i=1:length(TO)
		if TO(i) - t0 > 1
			row = row  +1;
			ts(row) = TO(i);
		end
		words(row,IO(i));
		t0 = TO(i);
	end
end
