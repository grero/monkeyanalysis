function ans = replayExperiment(offset,nsamples,edfdata,l)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Replay the experiment from the eye link data contained in the edfdata structure.
	%Inputs:
	%	offset		:		time point index from which to start the replay
	%	nsamples	:		number of time points to replay
	%	edfdata		:		eye link data structure contraining the experiment
	%	l			:		reference to a line plot handle
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin == 3
        %we were not given a line handle, so create it here
        figure
        axis
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
        %Try replacing with a fixation dot
        fill([144+2*xdiff, 144+3*xdiff, 144+3*xdiff, 144+2*xdiff],...
            [90+3*ydiff, 90+3*ydiff, 90+2*ydiff, 90+2*ydiff],[0.5,0.5,0.5]);
        xlim([0,1440]);
        ylim([0,900]);
    end
    lifetime = -1;
    nextevent = 1;
    %fast-forward the events based on the specified offset
    while edfdata.FEVENT(nextevent).sttime < edfdata.FSAMPLE.time(offset)
        nextevent = nextevent + 1;
    end
    for i=1:nsamples,
        %update the plot data
        set(l,'XData',edfdata.FSAMPLE.gx(1,offset+i),'YData',edfdata.FSAMPLE.gy(1,offset+i));
        %wait for 10 ms; this can be changed, and probably should be parameter
        pause(0.01);
        %check if there is an event at this time
        if edfdata.FEVENT(nextevent).sttime == edfdata.FSAMPLE.time(offset+i)
            m = edfdata.FEVENT(nextevent).message(1:3:end);
            if ~isempty(m)
                if ((m(1) == '0') && (m(2) == '1'))
                    %get the row and column index
                    px = bin2dec(m(5:-1:3))-1;
                    py = bin2dec(m(8:-1:6))-1;
                    lifetime = 0;
                end
            end
            nextevent = nextevent + 1;
                
        end
        
        %check if we have a target event
        if lifetime > -1
            %fill the appropriate square
            h = fill([144+px*xdiff, 144+(px+1)*xdiff, 144+(px+1)*xdiff, 144+px*xdiff],...
            [90+(py+1)*ydiff, 90+(py+1)*ydiff, 90+py*ydiff, 90+py*ydiff],'r');
                    %lifetime = 0;
                %end
        end
        %if we are plotting a target, increase it's life time by one
        if lifetime>-1
            lifetime = lifetime + 1;
        end
        %check if target should be extinguished; 50 is completely arbitrary here. It should be set based on the actual
        %sampling rate (2000 Hz) and the argument to pause above to simulate the actual target offset
        if lifetime >= 50
            delete(h); %for some reason this doesn't extinguish the target
            lifetime = -1;
        end
        title(sprintf('%d', edfdata.FSAMPLE.time(offset+i)))
        drawnow
    end
end
