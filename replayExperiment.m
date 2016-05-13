function M = replayExperiment(offset,nsamples,edfdata,samplingRate,l,rows,cols)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Replay the experiment from the eye link data contained in the edfdata structure.
	%Inputs:
	%	offset		:		time point index from which to start the replay
	%	nsamples	:		number of time points to replay
	%	edfdata		:		eye link data structure contraining the experiment
	%	l			:		reference to a line plot handle
    %   rows        :       number of rows used
    %   cols        :       number of columns
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rows = 5;
    cols = 5;
	screen_width = 1440;
    screen_height = 900;
    %this is taken directly from Jit Hon's DST code
    squareArea = floor((screen_height-screen_height/10)/rows);
    xmargin = (screen_width - cols * squareArea) / 2;
    ymargin = (screen_height - rows * squareArea) / 2;
    xdiff = (screen_width-2*xmargin)/cols;
    ydiff = (screen_height-2*ymargin)/rows;
    %%%%%%
	M = avifile('tmp.avi','FPS',25);
    if nargin == 4
        %we were not given a line handle, so create it here
        figure
        axis
        rectangle('Position', [xmargin,ymargin,screen_width-2*xmargin,screen_height-2*ymargin]);
        %the width and height of each square
        %xdiff = (screen_width-2*144)/5;
        %ydiff = (screen_height-2*90)/5;
        %draw the grid
        for j=0:rows-1
            line([xmargin, screen_width-xmargin], [ymargin+j*ydiff ymargin+j*ydiff],'Color','k');
        end
        for i=0:cols-1
            line([xmargin+i*xdiff, xmargin+i*xdiff], [ymargin screen_height-ymargin],'Color','k');
        end
        hold on
        %Try replacing with a fixation dot
        fp = fill([xmargin+2*xdiff, xmargin+3*xdiff, xmargin+3*xdiff, xmargin+2*xdiff],...
            [ymargin+3*ydiff, ymargin+3*ydiff, ymargin+2*ydiff, ymargin+2*ydiff],[0.5,0.5,0.5]);
        l = plot(edfdata.FSAMPLE.gx(1,1),edfdata.FSAMPLE.gy(1,1),'.');
        %draw a rectangle around the grid; these numbers are from Jit Hon's code
        rectangle('Position', [xmargin,ymargin,screen_width-2*xmargin,screen_height-2*ymargin]);
 
        %draw the grid
        for j=0:rows-1
            line([xmargin, screen_width-xmargin], [ymargin+j*ydiff ymargin+j*ydiff],'Color','k');
        end
        for i=0:cols-1
            line([xmargin+i*xdiff, xmargin+i*xdiff], [ymargin screen_height-ymargin],'Color','k');
        end
        hold on
        %draw the fixation rectangle; we probably shouldn't do this, since the monkey doens't see a rectangle. 
        xlim([0,screen_width]);
        ylim([0,screen_height]);
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
            h = fill([xmargin+px*xdiff, xmargin+(px+1)*xdiff, xmargin+(px+1)*xdiff, xmargin+px*xdiff],...
            [ymargin+(py+1)*ydiff, ymargin+(py+1)*ydiff, ymargin+py*ydiff, ymargin+py*ydiff],'r');
                %end
		elseif  dlifetime == 0
            h = fill([xmargin+px*xdiff, xmargin+(px+1)*xdiff, xmargin+(px+1)*xdiff, xmargin+px*xdiff],...
            [ymargin+(py+1)*ydiff, ymargin+(py+1)*ydiff, ymargin+py*ydiff, ymargin+py*ydiff],'g');
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
