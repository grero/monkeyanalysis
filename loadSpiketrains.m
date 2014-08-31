function sptrains = loadSpiketrains(fname)
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
	if nargin == 0
		files = dir('*Spiketrains.mat');
		if isempty(files)
			disp('No spike trains found')
			return
		end
		%load the first file
		sptrains_ = load(files(1).name);
	else
		if ischar(fname)
			sptrains_ = load(fname);	
		elseif isstruct(fname)
			sptrains_ = fname;
		end
	end
	F = fields(sptrains_);
	sptrains = struct;
    spikechannels = [];
  	area_sptrains = struct();
	for i=1:length(F)
		f = F(i);
		sidx = strfind(f{:}, '_');
		if isempty(sidx)
			q = sscanf(f{:}, 'g%dc%ds');
			sptrains.channels(q(1)).cluster(q(2)).spiketimes = getfield(sptrains_,f{:}); 
		else
			ss = f{:};
			area_name = ss(1:sidx(1)-1);
			spname = ss(sidx(1)+1:end);
			q = sscanf(ss(sidx(1)+1:end), 'g%dc%ds');
			if isfield(area_sptrains,area_name)
				qq = setfield(getfield(area_sptrains,area_name),spname,getfield(sptrains_,f{:}));
				area_sptrains = setfield(area_sptrains,area_name,qq);
			else
				area_sptrains = setfield(area_sptrains,area_name,struct(spname,getfield(sptrains_,f{:})));
			end
		end
        spikechannels = [spikechannels q(1)]; 
    end
	if ~isempty(fieldnames(area_sptrains))
		sptrains = struct();
		F = fieldnames(area_sptrains);
		for i=1:length(F)
			f = F(i);
			sptrains = setfield(sptrains,f{:},loadSpiketrains(getfield(area_sptrains,f{:})));
		end
	else
		sptrains.spikechannels = unique(spikechannels);
		sptrains.ntrains = length(F);
		unitsperchannel = zeros(1,length(sptrains.spikechannels));
		for i=1:length(sptrains.spikechannels)
			unitsperchannel(i) = length(sptrains.channels(sptrains.spikechannels(i)).cluster);
		end
		sptrains.unitsperchannel = unitsperchannel;
	end
end



