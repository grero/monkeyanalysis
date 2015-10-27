function status=nptWriteStreamerFile(filename,sampling_rate,data,transpose,scan_order)
%nptWriteStreamerFile Function to write binary files from Data Streamer
%function status=nptWriteStreamerFile(filename,sampling_rate,data,scan_order)
%scanorder is optional

num_channels=size(data,1);
if nargin < 4
	transpose = 0;
end

if transpose == 1
	header_size=75;
else
	header_size=74;
end

fid=fopen(filename,'w','ieee-le');
if fid~=-1
   status=1;
end
if nargin<5
   scan_order=zeros(1,64);
   pad=[];
else
   %pad scan_order to 64 numbers
   pad=zeros(1,64 - size(scan_order,1));
end

fwrite(fid, header_size, 'int32');					% 4 bytes reserved for header size which is 73 bytes
fwrite(fid,num_channels, 'uint16');				% 2 bytes
if transpose == 1
	fwrite(fid,transpose, 'int8');
end
fwrite(fid,sampling_rate, 'uint32');				% 4 bytes
fwrite(fid,scan_order,'uchar');				% 1 byte for each channel up to 64 channels
fwrite(fid,pad,'int8');
if transpose
	fwrite(fid, data', 'int16');
else
	fwrite(fid, data, 'int16');
end
fclose(fid);
