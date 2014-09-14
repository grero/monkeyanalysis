function M = replayExperiment(offset,nsamples,edfdata,samplingRate,decoded,M,l)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Replay the experiment from the eye link data contained in the edfdata structure.
	%Inputs:
	%	offset		:		time point index from which to start the replay
	%	nsamples	:		number of time points to replay
	%	edfdata		:		eye link data structure contraining the experiment
	%	l			:		reference to a line plot handle
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if nargin < 6	
		M = avifile('tmp.avi','FPS',10);
	end
	if nargin < 5 
		decoded = [];
	end
    if nargin < 7 
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
		%fixation point
		fp = rectangle('Position',[1440/2-25,900/2-25,50,50],'Curvature',[1 1],'FaceColor',[0.5,0.5,0.5],'EdgeColor','w');
		%decoded location
        dp = fill([144+2*xdiff, 144+3*xdiff, 144+3*xdiff, 144+2*xdiff],...
            [90+3*ydiff, 90+3*ydiff, 90+2*ydiff, 90+2*ydiff],'w');
		set(dp,'Edgecolor','k','FaceAlpha',0,'LineWidth',0.5)
		%reward indicator
        rp = fill([144+2*xdiff, 144+3*xdiff, 144+3*xdiff, 144+2*xdiff],...
            [90+3*ydiff, 90+3*ydiff, 90+2*ydiff, 90+2*ydiff],[0.5,0.5,0.5]);
		set(rp,'FaceAlpha',0,'LineWidth',0.5)
		%text to indicate the result of the trial
		T = text(1440/2,450,'');
        l = plot(edfdata.FSAMPLE.gx(1,1),edfdata.FSAMPLE.gy(1,1),'.',...
			'MarkerSize',20.0);
		%decoded position
        ddp = plot(10000,10000,'+','MarkerSize',20.0);
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
		axPos = get(gca,'Position'); %get the position of the axis in the figure
    end
	if nargin == 3
		samplingRate = 1;
	end
    tlifetime = -1;
	dlifetime = -1;
    nextevent = 1;
    %fast-forward the events based on the specified offset
	trialnr = 0;
	lasttarget = 0
	trialstart = NaN;
    while edfdata.FEVENT(nextevent).sttime <= edfdata.FSAMPLE.time(offset)
		m = edfdata.FEVENT(nextevent).message(1:3:end);
		if ~isempty(m)
			if strcmp(m,'00000000') %trial start
					trialnr  = trialnr + 1; %keep track of trials
					trialstart = edfdata.FEVENT(nextevent).sttime;
			elseif ((m(1) == '0') && (m(2) == '1')) %target
				lasttarget = nextevent;
			end
		end
        nextevent = nextevent + 1;
    end
	%fast forward to to the next event, which should be prestim
	while ~strcmpi(edfdata.FEVENT(nextevent).message(1:3:end),'00000001')
		nextevent = nextevent + 1;
	end
    while edfdata.FEVENT(nextevent).sttime >= edfdata.FSAMPLE.time(offset)
		offset  = offset + 1;
	end

	trialnr
	nextevent;
	i = 1;
	dostop = 0;
	while (i <= nsamples) && (dostop == 0)
    %for i=1:nsamples
        %update the plot data
		xx = double(edfdata.FSAMPLE.gx(1,offset+(i-1)*samplingRate+1:offset+i*samplingRate));
		xx(xx>10000) = nan;
		yy = double(edfdata.FSAMPLE.gy(1,offset+(i-1)*samplingRate+1:offset+i*samplingRate));
		yy(yy>10000) = nan;
        set(l,'XData',nanmean(xx),'YData',900-nanmean(yy));
        %wait for 10 ms; this can be changed, and probably should be parameter
		%original sampling rate is 2000 Hz, i.e. 0.5 ms between frames
        pause(0.0005*samplingRate);
        %check if there is an event at this time
		
		while edfdata.FEVENT(nextevent).sttime <  edfdata.FSAMPLE.time(offset+i*samplingRate)
        %if ismember(edfdata.FEVENT(nextevent).sttime,edfdata.FSAMPLE.time(offset+(i-1)*samplingRate+1:offset+i*samplingRate))
            m = edfdata.FEVENT(nextevent).message(1:3:end);
			edfdata.FEVENT(nextevent).codestring;
            if ~isempty(m)
                if ((m(1) == '0') && (m(2) == '1')) %target
                    %get the row and column index
                    px = bin2dec(m(5:-1:3))-1;
                    py = 5-bin2dec(m(8:-1:6));
                    tlifetime = 0;
					lasttarget = nextevent;
					title('Target')
				elseif ((m(1) == '1') && (m(2) == '0'))  %distractor
                    px = bin2dec(m(5:-1:3))-1;
                    py = 5-bin2dec(m(8:-1:6));
                    dlifetime = 0;
					title('Distractor')
				elseif strcmp(m, '00000000') %trial start
					set(fp,'FaceColor',[0.5,0.5,0.5])
					set(rp,'EdgeColor','k', 'LineWidth',0.1)
					set(T,'String','')
					trialnr  = trialnr + 1
					trialstart = edfdata.FEVENT(nextevent).sttime;
					title('Trial start')
				elseif strcmp(m,'00000101') %go-cueue
					set(fp,'FaceColor','w')
					title('Go-cue')
				elseif strcmp(m,'00000110') %reward
					%set(rp,'EdgeColor','g', 'LineWidth',3.0)
					set(T,'String','O','FontSize',36,'Color','g','HorizontalAlignment','center')
					title('Reward')
				elseif strcmp(m,'00000111') %failure
					%set(rp,'EdgeColor','r', 'LineWidth',3.0)
					set(T,'String','X','FontSize',36,'Color','r','HorizontalAlignment','center')
					title('Failure')
				elseif strcmpi(m,'00000011') %stimulus blank
					title('First delay')
				elseif strcmpi(m,'00000100') %delay
					title('Second delay')
				elseif strcmpi(m,'00000001') %fixation start
					title('Acquired fixation')
				elseif strcmpi(m,'00100000') %trial end
					title('End of trial')
					dostop = 1;
					break;
				end
            end
            nextevent = nextevent + 1;
                
        end
		if ismember(trialnr, decoded.test_orig) %check we have a decoding for this event
			try
				delete(dp);
				delete(aa);
			catch
			end
			t = edfdata.FSAMPLE.time(offset+(i-1)*samplingRate+1:offset+i*samplingRate);
			tidx = find(decoded.test_orig==trialnr);
			[n,b] = histc(t-trialstart,decoded.bins+decoded.targettime(trialnr));
			ib = mode(b((b>0)&(b<length(decoded.bins))));
			try
				ll = decoded.locations(tidx,ib);
				[c,r] = ind2sub([decoded.nrows,decoded.ncols],ll);
				if isfield(decoded,'posterior')
					%total hack
					if ll > 5
						llx = ll -1;
					else
						llx = ll;
					end
					 %[xm,ym] = meshgrid(1:decoded.ncols, decoded.nrows:-1:1);
					 [ym,xm] = meshgrid(decoded.nrows:-1:1,1:decoded.ncols);
					 pp = decoded.posterior(tidx,:,ib);
					 pp(isnan(pp)) = 0;
					 pp = [pp(1:4) 0 pp(5:8)]./sum(pp);
					 xm = pp*(xm(:)-2) %centralize
					 ym = pp*(ym(:)-2)
					 set(ddp,'XData',((xm+2.5)*xdiff),'YData',((2.5+ym)*ydiff),...
						 'color','k');%,[1.0,0.5,0.5])
					if decoded.posterior(tidx,llx,ib) > 1/8
						dp = highlightSquare(dp,5-r,c+1,xdiff,ydiff);
					else
						dp = highlightSquare(dp,3,3,xdiff,ydiff);
					end
				else
					[dp,aa] = highlightSquare(dp,5-r,c+1,xdiff,ydiff);
				end
			catch e
			e.message
			e.stack
			end
		else
			try
				delete(dp);
				delete(aa);
			catch
			end
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
        %title(sprintf('%d', edfdata.FSAMPLE.time(offset+(i-1)*samplingRate)))
        drawnow
		M = addframe(M,getframe(gcf));
		i = i+1;
    end
	if nargout == 0
		M = close(M);
	end

	function [dp,aa] = highlightSquare(dp,row,col,xdiff,ydiff)
        dp = fill([144+(col-1)*xdiff, 144+col*xdiff, 144+col*xdiff, 144+(col-1)*xdiff],...
            [90+row*ydiff, 90+row*ydiff, 90+(row-1)*ydiff, 90+(row-1)*ydiff],'w');
		set(dp,'Edgecolor','m','FaceAlpha',0,'LineWidth',2.0)
		if nargout == 2
			%annotate
			axPos = get(gca,'Position');
			xa(2) = axPos(1) + (((144+col*xdiff))/1440)*axPos(3);
			xa(1) = axPos(1) + (((144+(col+0.5)*xdiff))/1440)*axPos(3);

			ya(2) = axPos(2) + (((90+row*ydiff))/900)*axPos(3);
			ya(1) = axPos(2) + (((90+(row+0.5)*ydiff))/900)*axPos(3);
			aa = annotation('textarrow', xa, ya,'String','Decoded position');
		end
	end 
end
