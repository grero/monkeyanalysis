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
	[pth,fn,ex] = fileparts(fname);
	mkdir('.','highpass');
	mkdir('.','lowpass');
	lowpassOutput = ['lowpass/' fn '_lowpass.bin'];
	if nargin == 1
		chunksize = 100;
	end
	if nargin <=3
		redo = 0;
	end

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
	%check if we are only analyzing a single chunck
	if nargin >= 3
		chunks = chunks(chunkidx:chunkidx+1)
	end

	%get the strobed events
	readStrobes(fname);
	%main processing loop
	fprintf(1,'Processing wide band signal\n');
	H = zeros(nchannels,chunksize,'int16');
	L = zeros(nchannels,chunksize,'int16');
	try
		for i=1:length(chunks)-1
			hcsize = chunks(i+1)-chunks(i);
			lcsize = hcsize/(pl2.TimestampFrequency/1000);
			%check whether this chunk already exists
			hfname = sprintf('highpass/%s_highpass.%.4d',fn,i);
			lfname = sprintf('lowpass/%s_lowpass.%.4d',fn,i);
			fprintf(1,'\tAnalyzing chunk %d\n', i);
			if exist(hfname,'file') && exist(lfname,'file')
				fprintf('\t\tChunk already processed. Skipping...\n')
				continue
			end
			for ch=1:length(WBChannels)
				%get the wideband data
				fprintf(1,'\t\tReading channel %d\n', WBChannels(ch));
				ad = Pl2adSpan(fname,WBChannels(ch),chunks(i)+1,chunks(i+1));
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
			nptWriteStreamerFile(hfname,pl2.TimestampFrequency,H);
			fprintf(1,'\tSaving lowhpass filtered chunk to %s\n',lfname);
			nptWriteStreamerFile(lfname,1000,L(:,1:lcsize));
		end
	catch  e
		disp('An error occurred');
		e.identifier
		e.message
	end


