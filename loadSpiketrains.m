function sptrains = loadSpiketrains()
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Load spike trains from the current working directory. Search for files with signature
	%*Spiketrains.mat in the current directory and returns a structure corresponding to the 
	%sorted spike trains
	%Output:
	%	sptrains.spikechannels		:		channels with at least one unit
	%	sptrains.channels(i).cluster(j).spiketimes	:	the spike times of unit j on channel i, in units of miliseconds
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%search for eligible spiketrains
	sptrains = [];
	files = dir('*Spiketrains.mat');
	if isempty(files)
		disp('No spike trains found')
		return
	end
	%load the first file
	sptrains_ = load(files(1).name);
	F = fields(sptrains_);
	sptrains = struct;
    spikechannels = [];
	for i=1:length(F)
		f = F(i);
		q = sscanf(f{:}, 'g%dc%ds');
        spikechannels = [spikechannels q(1)];
		sptrains.channels(q(1)).cluster(q(2)).spiketimes = getfield(sptrains_,f{:});
    end
    sptrains.spikechannels = unique(spikechannels);
end



