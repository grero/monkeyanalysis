function M = replayExperiment(offset,nsamples,edfdata,samplingRate,l)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Replay the experiment from the eye link data contained in the edfdata structure.
	%Inputs:
	%	offset		:		time point index from which to start the replay
	%	nsamples	:		number of time points to replay
	%	edfdata		:		eye link data structure contraining the experiment
	%	l			:		reference to a line plot handle
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	M = avifile('tmp.avi','FPS',25);
    if nargin == 4
        %we were not given a line handle, so create it here
        figure
        axis
        rectangle('Position', [144,90,1440-2*144,900-2*90]);
        %the width and height of each square
        xdiff = (1440-2*144)/5;
        ydiff = (900-2*90)/5;
        %draw the grid
        for j=0:4
            line([144, 1440-144], [90+j*ydiff 90+j*ydiff],'Color','k');
        end
        for i=0:4
            line([144+i*xdiff, 144+i*xdiff], [90 900-90],'Color','k');
        end
        hold on
        %Try replacing with a fixation dot
        fp = fill([144+2*xdiff, 144+3*xdiff, 144+3*xdiff, 144+2*xdiff],...
            [90+3*ydiff, 90+3*ydiff, 90+2*ydiff, 90+2*ydiff],[0.5,0.5,0.5]);
        l = plot(edfdata.FSAMPLE.gx(1,1),edfdata.FSAMPLE.gy(1,1),'.');
        %draw a rectangle around the grid; these numbers are from Jit Hon's code
        rectangle('Position', [144,90,1440-2*144,900-2*90]);
        %the width and height of each square
        xdiff = (1440-2*144)/5;
        ydiff = (900-2*90)/5;
        %draw the grid
        for j=0:4
            line([144, 1440-144], [90+j*ydiff 90+j*ydiff],'Color','k');
        end
        for i=0:4
            line([144+i*xdiff, 144+i*xdiff], [90 900-90],'Color','k');
        end
        hold on
        %draw the fixation rectangle; we probably shouldn't do this, since the monkey doens't see a rectangle. 
        xlim([0,1440]);
        ylim([0,900]);
    end
	if nargin == 3
		samplingRate = 1;
	end
    tlifetime = -1;
	dlifetime = -1;
    nextevent = 1;
    %fast-forward the events based on the specified offset
    while edfdata.FEVENT(nextevent).sttime < edfdata.FSAMPLE.time(offset)
        nextevent = nextevent + 1;
    end
	nextevent
    for i=1:nsamples,
        %update the plot data
		xx = double(edfdata.FSAMPLE.gx(1,offset+(i-1)*samplingRate+1:offset+i*samplingRate));
		xx(xx>10000) = nan;
		yy = double(edfdata.FSAMPLE.gy(1,offset+(i-1)*samplingRate+1:offset+i*samplingRate));
		yy(yy>10000) = nan;
        set(l,'XData',nanmean(xx),'YData',nanmean(yy));
        %wait for 10 ms; this can be changed, and probably should be parameter
		%original sampling rate is 2000 Hz, i.e. 0.5 ms between frames
        pause(0.0005*samplingRate);
        %check if there is an event at this time
		while edfdata.FEVENT(nextevent).sttime <  edfdata.FSAMPLE.time(offset+i*samplingRate)
        %if ismember(edfdata.FEVENT(nextevent).sttime,edfdata.FSAMPLE.time(offset+(i-1)*samplingRate+1:offset+i*samplingRate))
            m = edfdata.FEVENT(nextevent).message(1:3:end);
			edfdata.FEVENT(nextevent).codestring
            if ~isempty(m)
                if ((m(1) == '0') && (m(2) == '1')) %target
                    %get the row and column index
                    px = bin2dec(m(5:-1:3))-1;
                    py = bin2dec(m(8:-1:6))-1;
                    tlifetime = 0;
				elseif ((m(1) == '1') && (m(2) == '0'))  %distractor
                    px = bin2dec(m(5:-1:3))-1;
                    py = bin2dec(m(8:-1:6))-1;
                    dlifetime = 0;
				elseif strcmp(m, '00000000') %trial start
					set(fp,'FaceColor',[0.5, 0.5, 0.5])
				elseif strcmp(m,'00000101') %go-cueue
					set(fp,'FaceColor','w')
                end
            end
            nextevent = nextevent + 1;
                
        end
        
        %check if we have a target event
        if tlifetime == 0 
            %fill the appropriate square
            h = fill([144+px*xdiff, 144+(px+1)*xdiff, 144+(px+1)*xdiff, 144+px*xdiff],...
            [90+(py+1)*ydiff, 90+(py+1)*ydiff, 90+py*ydiff, 90+py*ydiff],'r');
                %end
		elseif  dlifetime == 0
            h = fill([144+px*xdiff, 144+(px+1)*xdiff, 144+(px+1)*xdiff, 144+px*xdiff],...
            [90+(py+1)*ydiff, 90+(py+1)*ydiff, 90+py*ydiff, 90+py*ydiff],'g');
        end
        %if we are plotting a target, increase it's life time by one
        if tlifetime>-1
            tlifetime = tlifetime + 1;
		elseif dlifetime > -1
            dlifetime = dlifetime + 1;
        end
        %check if target should be extinguished; 50 is completely arbitrary here. It should be set based on the actual
        %sampling rate (2000 Hz) and the argument to pause above to simulate the actual target offset
        if tlifetime >= 300*2/samplingRate 
            delete(h); %for some reason this doesn't extinguish the target
            tlifetime = -1;
		elseif dlifetime >= 300*2/samplingRate
			delete(h);
            dlifetime = -1;
        end
        title(sprintf('%d', edfdata.FSAMPLE.time(offset+(i-1)*samplingRate)))
        drawnow
		M = addframe(M,getframe(gcf));
    end
	M = close(M);
end
