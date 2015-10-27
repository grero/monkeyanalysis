function status = FilterPl2(fname,chunksize,chunkidx,redo)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Extracts strobe events as well as lowpass- and highpass filters wide band data contained in a pl2 file
	%Inputs:
	%	fname		:		name of the pl2 file to use
	%	chunksize	:		size, in seconds,  of each of the chunks into which the wide band data is divided. Defaults to 100 s
	%	chunkidx	:		optional argument to indicate a specific chunk to analyze. The chunk index is calculated from the specified chunk size
	%	redo		:		optional argument to redo all computation, even if data already exist
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	%
	status = 0;
	[pth,fn,ex] = fileparts(fname);
	mkdir('.','highpass');
	mkdir('.','lowpass');
	lowpassOutput = ['lowpass/' fn '_lowpass.bin'];
	if nargin == 1
		chunksize = 100;
	elseif ischar(chunksize)
		chunksize = str2num(chunksize);
	end
	if nargin <=3
		redo = 0;
	end
	%get the strobed events
	readStrobes(fname);

	%get the available channels
	pl2 = PL2GetFileIndex(fname);

	%get the index of the WB channels
	WBChannels = [];
	for i=1:length(pl2.AnalogChannels)
		if strcmpi(pl2.AnalogChannels{i}.SourceName,'WB')
			WBChannels = [WBChannels i];
		end
	end
	nchannels = length(WBChannels);
	%construct chunks
	%convert ticks
	samplingRate = pl2.TimestampFrequency;
	chunksize = chunksize*samplingRate;
	chunks = 0:chunksize:pl2.DurationOfRecordingTicks;
	%make sure we pick up the last chunk as well
	if pl2.DurationOfRecordingTicks-chunks(end)>0
		chunks = [chunks pl2.DurationOfRecordingTicks];
	end
	if ~exist('best_chunk.txt','file')
		%get the best chunk, i.e. the one containing the most number of trials
		%read the trials back so that we can get the master chunk
		trials = loadTrialInfo('event_data.mat');
		%get the start time of each trial, in seconds
		starttime = getEventTimingDistr(trials,'start')/1000;
		n = histc(starttime, 0:chunksize/samplingRate:length(chunks)*chunksize/samplingRate);
		[ntrials,best_chunk] = max(n);
		fid = fopen('best_chunk.txt','w');
		fprintf(fid,'%d\n', best_chunk);
		fclose(fid);
	else
		fid = fopen('best_chunk.txt','r');
		best_chunk = fscanf(fid,'%d');
		fclose(fid);
	end
	%check if we are only analyzing a single chunck
	if nargin >= 3
		if ischar(chunkidx)
			if strcmpi(chunkidx,'best')
				chunkidx = best_chunk;
				fprintf(1,'Processing best chunk, chunk %d\n', best_chunk);
			else
				chunkidx = str2num(chunkidx)
			end
		end
		chunks = chunks(chunkidx:chunkidx+1)
	end

	%main processing loop
	fprintf(1,'Processing wide band signal\n');
	H = zeros(nchannels,chunksize,'int16');
	L = zeros(nchannels,chunksize,'int16');
	try
		for i=1:length(chunks)-1
			ci = chunkidx(i);
			hcsize = chunks(i+1)-chunks(i);
			lcsize = hcsize/(pl2.TimestampFrequency/1000);
			%check whether this chunk already exists
			hfname = sprintf('highpass/%s_highpass.%.4d',fn,ci);
			lfname = sprintf('lowpass/%s_lowpass.%.4d',fn,ci);
			fprintf(1,'\tAnalyzing chunk %d\n', ci);
			if exist(hfname,'file') && exist(lfname,'file')
				fprintf('\t\tChunk already processed. Skipping...\n')
				continue
			end
			for ch=1:length(WBChannels)
				%get the wideband data
				fprintf(1,'\t\tReading channel %d\n', WBChannels(ch));
				ad = PL2AdSpan(fname,WBChannels(ch),chunks(i)+1,chunks(i+1));
				if isempty(ad.Values)
					continue
				end
				%highpass filter using nptHighpass	
				%convert to microvolts before storing as int16
				fprintf(1,'\t\t\tHighpass filtering...\n');
				H(ch,1:hcsize) = (nptHighPassFilter(ad.Values, ad.ADFreq)*1e3);
				fprintf(1,'\t\t\tLowpass filtering...\n');
				L(ch,1:lcsize) = (nptLowPassFilter(ad.Values, ad.ADFreq)*1e3);
			end
			fprintf(1,'\tSaving highpass filtered chunk to %s\n',hfname);
			nptWriteStreamerFile(hfname,pl2.TimestampFrequency,H,1);
			fprintf(1,'\tSaving lowhpass filtered chunk to %s\n',lfname);
			nptWriteStreamerFile(lfname,1000,L(:,1:lcsize));
		end
	catch  e
		disp('An error occurred');
		e.identifier
		e.message
	end


