function readStrobes(fname)

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
    strobeFile = 'event_data.mat';
    if ~exist(strobeFile,'file')
		fprintf(1,'Reading strobe events\n');
		events = PL2EventTs(fname,'Strobed');
		%to align events to the continuous recording, subtract the initial delay from the events
		%check if we have more than one fragment
		%this is hackish; to get the frag time stamp, re-read one channel
		ad = PL2Ad(fname,WBChannels(1));
        if isempty(ad.Values)
            ad = Pl2Ad(fname,513);
        end
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
		fprintf(1,'Saving strobe events to file %s\n',strobeFile);
		save(strobeFile,'ts','sv');
    end
end