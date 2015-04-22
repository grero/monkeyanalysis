function [data,num_channels,sampling_rate,datatype,points]=nptReadDataFile(rawfile,channel)
%nptReadDataFile Function to read binary files similiar to Streamer files
%	[DATA,NUM_CHANNELS,SAMPLING_RATE,DATATYPE,POINTS] = nptReadDataFile(FILENAME)
% 	opens the file FILENAME and returns the data in a matrix DATA with 
%	the data for each channel in a row. The data is in millivolts. 
%	NUM_CHANNELS is the number of channels. SAMPLING_RATE is the 
%	sampling rate used in the data collection. DATATYPE is listed below. POINTS returns
%	the number of data points in each channel.
%
% datatype is as follows:
% 1 => 'uchar';  
% 2 => 'schar';   
% 3 => 'int8';    
% 4 => 'int16';  
% 5 => 'int32';   
% 6 => 'int64';   
% 7 => 'uint8';   
% 8 => 'uint16';  
% 9 => 'uint32';  
% 10 => 'uint64';  
% 11 => 'single';  
% 12 => 'float32'; 
% 13 => 'double';  
% 14 => 'float64'; 
if nargin == 1
	channel = inf 
end

is_transposed = 0;
fid=fopen(rawfile,'r','ieee-le');
header_size=fread(fid, 1, 'int32')					% 4 bytes reserved for header size which is 73 bytes
if header_size >= 74
	num_channels=fread(fid, 1, 'uint16');				% 1 byte
	if header_size == 75
		is_transposed = fread(fid, 1, 'uint8')
	end
else
	num_channels=fread(fid, 1, 'uint8');				% 1 byte
end
sampling_rate=fread(fid, 1, 'uint32');				% 4 bytes
datatype = fread(fid,1,'int8');	% datatype assume for now int16 
fseek(fid, 0, 'eof');
fsize = ftell(fid);
points = (fsize - header_size)/num_channels/2
fseek(fid, header_size, 'bof');						% skip to the end 

	if is_transposed == 0
		if channel ==  inf
			[data,count]=fread(fid, [num_channels,inf], 'int16');
		else
			fseek(fid, (channel(1)-1)*2,0)
			[data,count]=fread(fid, [1,points], 'int16',num_channels);
		end

	else
		if channel ==  inf
			[data,count]=fread(fid, [inf, num_channels], 'int16');
			data = data';
		else
			fseek(fid, (channel(1)-1)*2*points,0)
			[data,count]=fread(fid, [1,points], 'int16');
		end

	end

fclose(fid);
