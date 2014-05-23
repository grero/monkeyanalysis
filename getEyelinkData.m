function [data,EE] = getEyelinkData(EE,dosave)
	if nargin < 2
		dosave = false;
	end
    if ischar(EE)
        EE = edfmex(EE);
    end
        
    %get the screen resolution
    time = sscanf(EE.FEVENT(1).message, '%*s %*d %*d %d %d',[1,inf]);
    width = time(1);
    height = time(2);
    %parse eye events
	fixations = [];
	%fixations = struct('start_time', [],'end_time', [],'start_time',[],'end_time',[])
	saccades = struct('start_pos', [],'end_pos', [],'start_time',[],'end_time',[])
    saccstart = [];
    saccend = [];
	rewards = [];
	failures = [];
	targets = [];
	strobes = [];
	timestamps = [];
    for i=1:length(EE.FEVENT) 
        gstx = EE.FEVENT(i).gstx;
        gsty = EE.FEVENT(i).gsty;
        genx = EE.FEVENT(i).genx;
        geny = EE.FEVENT(i).geny;
		sttime = EE.FEVENT(i).sttime;
		endtime = EE.FEVENT(i).entime;
        if strcmpi(EE.FEVENT(i).codestring,'startfix')
            fixations = [fixations [gstx; gsty]];
        elseif strcmpi(EE.FEVENT(i).codestring, 'endsacc')
            saccend = [saccend [genx; geny]];
            saccstart = [saccstart [gstx; gsty]];
			saccades.start_pos = [saccades.start_pos  [gstx; gsty]];
			saccades.end_pos = [saccades.end_pos  [genx; geny]];
			saccades.start_time = [saccades.start_time  sttime];
			saccades.end_time = [saccades.end_time  endtime];
		elseif strcmpi(EE.FEVENT(i).codestring, 'messageevent')
			w = str2num(EE.FEVENT(i).message);
			if length(w) ==8
				q = 2.^[12:-1:0]*[[1 0 0 0 1] ~w]'; 
				strobes = [strobes q];
				timestamps = [timestamps sttime];
				if all(w == [0,0,0,0,0,1,1,0])
					rewards = [rewards sttime];
				elseif all(w == [0,0,0,0,0,1,1,1])
					failures = [failures sttime];
				elseif (w(1) == 0) && (w(2) == 1)
					targets = [targets sttime];
				end
			end
        end
    end
	%save strobes
	if ~exist('event_data.mat','file')
		ts = timestamps;
		sv = strobes;
		save('event_data.mat', 'ts','sv')
	end
    data.fixations = fixations;
    data.sacc_start = saccstart;
    data.sacc_end = saccend;
    data.screen_width = width;
    data.screen_height = height;
	data.saccades = saccades;
	data.rewards = rewards;
	data.failures = failures;
	data.targets = targets;
	%get the center saccades, i.e. saccades which starting points from the center of the screen
	%assume 250 pixel window
	cx = width/2;
	cy = height/2;
	center_saccades = find((saccades.start_pos(1,:) > cx - 125)&(saccades.start_pos(1,:)<cx + 125)...
							&(saccades.start_pos(2,:) > cy - 125)&(saccades.start_pos(2,:) < cy + 125));
	%get the first saccade following target onset
	AA = repmat(data.targets,[size(saccades.start_pos,2),1]);
	DD = repmat(double(data.saccades.start_time)',[1,size(AA,2)])-double(AA);
	DD(DD<0) = inf;
	data.center_saccades = center_saccades;
	[mx,sidx] = min(DD,[],1);
	data.first_saccades = sidx;
	%find the rewarded saccades; find the first reward after the saccade end
	AA = double(repmat(data.rewards,[length(data.first_saccades),1]));
	DD = AA-repmat(double(data.saccades.end_time(data.first_saccades))',[1,size(AA,2)]);
	DD(DD<0) = inf;
	[rmx,ridx] = min(DD,[],1);
	data.rewarded_saccades = data.first_saccades(ridx);
	if dosave
		save('parsed_eye_data.mat', data);
end
