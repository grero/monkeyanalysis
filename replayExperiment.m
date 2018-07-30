function [tidx,M] = replayExperiment(offset,nsamples,edfdata,samplingRate,mytidx, decoded,M,l)
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
	if nargin < 6 
		decoded = [];
    end
    
    screen_height = 1200;
    screen_width= 1920;
    rows = 21;
    cols = 21;
    %parse the data first
    qq = parseEDFData(edfdata,rows,cols);
    %get the unique rows and columns
    rowcol = [];
    tidx = [];
    stimulated = [];
    response = [];
    reward = [];
    for i=1:length(qq.trials)
        if ~isempty(qq.trials(i).target)
            rowcol = [rowcol; [qq.trials(i).target.row qq.trials(i).target.column]];
        end
    end
      
    if nargin < 5
        for i=1:length(qq.trials)
            if ~isempty(qq.trials(i).target)
                if qq.trials(i).target.row == 15 && qq.trials(i).target.column == 15
                    tidx = [tidx i];
                    stimulated = [stimulated ~isempty(qq.trials(i).stim)];
                    response = [response ~isempty(qq.trials(i).response_cue)];
                    reward = [reward ~isempty(qq.trials(i).reward)];
                end
            end
        end
        %tidx = tidx(find(response));
        %stimulated = stimulated(find(response));
        ntrials = min(2, floor(length(tidx)/2));
        iidx = [randsample(intersect(find(stimulated),find(response)),ntrials), randsample(intersect(find(~stimulated), find(reward)),ntrials)];
        tidx = sort(tidx(iidx));
    else
        tidx = mytidx;
    end
    ntrials = length(tidx)
    locations = unique(rowcol,'rows');
    
    square_area = floor((screen_height-screen_height/10)/rows);
    xmargin = (screen_width - cols*square_area)/2;
    ymargin = (screen_height - rows*square_area)/2;
    xdiff = (screen_width - 2*xmargin)/cols;
    ydiff = (screen_height - 2*ymargin)/rows;
    
    trace_on = false;
    traces = [];
    if nargin < 7 
        %we were not given a line handle, so create it here
        figure
        axis
        set(gcf,'PaperUnits', 'Points')
        set(gcf, 'Position', [1 1 1200 686])
        if isempty(locations)
            rectangle('Position', [xmargin,ymargin,screen_width-2*xmargin,screen_height-2*ymargin]);
        end
        %the width and height of each square
        
        %draw the grid
        if isempty(locations)
            for j=0:rows
                line([xmargin, screen_width-xmargin], [ymargin+j*ydiff ymargin+j*ydiff],'Color','k');
            end
            for i=0:cols
                line([xmargin+i*xdiff, xmargin+i*xdiff], [ymargin screen_height-ymargin],'Color','k');
            end
        else
            plot_locations;
        end
        hold on
        %response square
        %h2 = fill([xmargin+(px-2)*xdiff, xmargin+(px+3)*xdiff, xmargin+(px+3)*xdiff, xmargin+(px-2)*xdiff],...
        %    [ymargin+(rows-py-2)*ydiff, ymargin+(rows-py-2)*ydiff, ymargin+(rows-py+3)*ydiff, ymargin+(rows-py+3)*ydiff],[1.0, 1.0, 1.0]);
        h2 = rectangle('Position', [xmargin, ymargin, 4*xdiff, 4*ydiff], 'FaceColor', 'w', 'EdgeColor', 'w');
		%fixation point
		fp = rectangle('Position',[screen_width/2-25,screen_height/2-25,50,50],'Curvature',[1 1],'FaceColor',[0.5,0.5,0.5],'EdgeColor','w');
		%decoded location
        dp = fill([xmargin+2*xdiff, xmargin+3*xdiff, xmargin+3*xdiff, xmargin+2*xdiff],...
            [ymargin+3*ydiff, ymargin+3*ydiff, ymargin+2*ydiff, ymargin+2*ydiff],'w');
		set(dp,'Edgecolor','k','FaceAlpha',0,'LineWidth',0.5)
		%stim indicator
        %rp = fill([xmargin+2*xdiff, xmargin+3*xdiff, xmargin+3*xdiff, xmargin+2*xdiff],...
        %    [ymargin+3*ydiff, ymargin+3*ydiff, ymargin+2*ydiff, ymargin+2*ydiff],[1.0,1.0,1.0]);
		%set(rp,'FaceAlpha',0,'LineWidth',0.5)
		%text to indicate the result of the trial
		T = text(screen_width/2,screen_height/2,'');
        lp = plot(edfdata.FSAMPLE.gx(1,offset),edfdata.FSAMPLE.gy(1,offset),'.',...
			'MarkerSize',20.0);
        ll = plot(edfdata.FSAMPLE.gx(1,offset),edfdata.FSAMPLE.gy(1,offset),'-',...
			'LineWidth',1.0,'color',[1.0, 1.0, 1.0]);
		%decoded position
        ddp = plot(10000,10000,'+','MarkerSize',20.0);
        %draw a rectangle around the grid; these numbers are from Jit Hon's code
        if isempty(locations)
            rectangle('Position', [xmargin,ymargin,screen_width-2*xmargin,screen_height-2*ymargin]);
        end
        %the width and height of each square
        %draw the grid
        if isempty(locations)
            for j=0:rows
                line([xmargin, screen_width-xmargin], [ymargin+j*ydiff ymargin+j*ydiff],'Color','k');
            end
            for i=0:cols
                line([xmargin+i*xdiff, xmargin+i*xdiff], [ymargin screen_height-ymargin],'Color','k');
            end
        else
            plot_locations;
        end
                
        hold on
        %draw the fixation rectangle; we probably shouldn't do this, since the monkey doens't see a rectangle. 
        xlim([0,screen_width]);
        ylim([0,screen_height]);
		axPos = get(gca,'Position'); %get the position of the axis in the figure
    end
	if nargin == 3
		samplingRate = 1;
	end
    tlifetime = -1;
	dlifetime = -1;
    glifetime = -1;
    nextevent = 0;
    %fast-forward the events based on the specified offset
	trialnr = 0;
	lasttarget = 0
	trialstart = NaN;
    for tt=1:ntrials
    tidx(tt)    
    while (nextevent < length(edfdata.FEVENT)) && (trialnr < tidx(tt))
    %while edfdata.FEVENT(nextevent).sttime <= edfdata.FSAMPLE.time(offset)
        nextevent = nextevent + 1;
		m = edfdata.FEVENT(nextevent).message(1:3:end);
		if ~isempty(m)
			if strcmp(m,'00000000') %trial start
					trialnr  = trialnr + 1; %keep track of trials
                    
					trialstart = edfdata.FEVENT(nextevent).sttime;
			elseif ((m(1) == '0') && (m(2) == '1')) %target
				lasttarget = nextevent;
			end
		end
        
    end
    
	%fast forward to to the next event, which should be prestim
	%while ~strcmpi(edfdata.FEVENT(nextevent).message(1:3:end),'00000001')
	%	nextevent = nextevent + 1;
	%end
    while edfdata.FEVENT(nextevent).sttime >= edfdata.FSAMPLE.time(offset)
		offset  = offset + 1;
    end
    %fast forward to right before the target onset
    
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
        xmm = nanmean(xx);
        ymm = screen_height-nanmean(yy);
        set(lp,'XData',xmm,'YData',ymm);
        pxm = get(ll,'XData');
        pym = get(ll, 'YData');
        if trace_on
            set(ll, 'XData',[pxm xmm], 'YData', [pym ymm]);
        end
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
                    if length(m) == 8
                        px = bin2dec(m(5:-1:3))-1;
                        py = bin2dec(m(8:-1:6))-1;
                    elseif length(m) == 14
                        px = bin2dec(m(8:-1:3))-1;
                        py = bin2dec(m(end:-1:9))-1;
                    end
                    tlifetime = 0;
					lasttarget = nextevent;
					title('Target')
				elseif ((m(1) == '1') && (m(2) == '0'))  %distractor
                    if length(m) == 8
                        px = bin2dec(m(5:-1:3))-1;
                        py = bin2dec(m(8:-1:6))-1;
                    elseif length(m) == 14
                        px = bin2dec(m(8:-1:3))-1;
                        py = bin2dec(m(end:-1:9))-1;
                    end
                    dlifetime = 0;
					title('Distractor')
				elseif strcmp(m, '00000000') %trial start
					set(fp,'FaceColor',[0.5,0.5,0.5])
					%set(rp,'EdgeColor','k', 'LineWidth',0.1)
                    %set(rp,'FaceColor',[1.0,1.0,1.0]);
					set(T,'String','')
					if edfdata.FEVENT(nextevent).sttime ~= trialstart
                        trialnr  = trialnr + 1
                        trialstart = edfdata.FEVENT(nextevent).sttime;
                    end
                    %fast forward to 300 ms before target
                    if ~isempty(qq.trials(trialnr).target)
                        while edfdata.FSAMPLE.time(offset+i*samplingRate) < qq.trials(trialnr).target.timestamp - 300
                            offset = offset + 1;
                        end
                    end
					title('Trial start')
                    
				elseif strcmp(m,'00000101') %go-cueue
					set(fp,'FaceColor','w')
                    glifetime = 0;
					title('Go-cue')
                    %turn on saccade trace
                    trace_on = true;
                    set(ll, 'XData', [xmm], 'YData', [ymm],'Color','b');
                  
                    
                            
                elseif strcmpi(m,'00001111') %stimulation
    
                    set(fp, 'FaceColor', 'y')
                    %set(rp,'FaceColor','y');
                    title('Stimulation')
				elseif strcmp(m,'00000110') %reward
                    glifetime = -1;
                    set(h2, 'FaceColor', 'w');
					%set(rp,'EdgeColor','g', 'LineWidth',3.0)
					set(T,'String','O','FontSize',36,'Color','g','HorizontalAlignment','center')
                    trace_on = false;
                    set(ll, 'Color', 'g');
                    set(gca, 'Children', [get(gca, 'Children'); line(get(ll, 'XData'), get(ll, 'YData'), 'Color', 'g', 'LineWidth', 1.0)]);
                    traces = [traces ll];
					title('Reward')
				elseif strcmp(m,'00000111') %failure
					%set(rp,'EdgeColor','r', 'LineWidth',3.0)
					set(T,'String','X','FontSize',36,'Color','r','HorizontalAlignment','center')
                    trace_on = false;
                    set(h2, 'FaceColor', 'w');
                    set(ll, 'Color', 'r');
                    set(gca, 'Children', [get(gca, 'Children'); line(get(ll, 'XData'), get(ll, 'YData'), 'Color', 'r', 'LineWidth', 1.0)]);
                    traces = [traces ll];
					title('Failure')
				elseif strcmpi(m,'00000011') %stimulus blank
					title('First delay')
				elseif strcmpi(m,'00000100') %delay
					title('Delay')
				elseif strcmpi(m,'00000001') %fixation start
					title('Acquired fixation')
				elseif strcmpi(m,'00100000') %trial end
					title('End of trial')
                    set(T, 'String', '');                  
					dostop = 1;
                    %set(rp, 'FaceColor', 'w');
                    
					break;
				end
            end
            nextevent = nextevent + 1;
                
        end
		if ~isempty(decoded) && ismember(trialnr, decoded.test_orig) %check we have a decoding for this event
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
        
        if glifetime == 0 %draw the response window around the target
            %h2 = fill([xmargin+(px-2)*xdiff, xmargin+(px+3)*xdiff, xmargin+(px+3)*xdiff, xmargin+(px-2)*xdiff],...
            %[ymargin+(rows-py-2)*ydiff, ymargin+(rows-py-2)*ydiff, ymargin+(rows-py+3)*ydiff, ymargin+(rows-py+3)*ydiff],[0.5, 0.5, 0.5]);
            set(h2, 'Position', [xmargin + (px-1.5)*xdiff, ymargin + (rows - py - 2.5)*ydiff, 4*xdiff, 4*ydiff]);
            set(h2, 'FaceColor', [0.5, 0.5, 0.5]);
        end 
        %check if we have a target event
        if tlifetime == 0 
            %fill the appropriate square
            h = fill([xmargin+px*xdiff, xmargin+(px+1)*xdiff, xmargin+(px+1)*xdiff, xmargin+px*xdiff],...
            [ymargin+(rows-py)*ydiff, ymargin+(rows-py)*ydiff, ymargin+(rows-py-1)*ydiff, ymargin+(rows-py-1)*ydiff],'r');
                %end
		elseif  dlifetime == 0
            h = fill([xmargin+px*xdiff, xmargin+(px+1)*xdiff, xmargin+(px+1)*xdiff, xmargin+px*xdiff],...
            [ymargin+(py+1)*ydiff, ymargin+(rows-py)*ydiff, ymargin+py*ydiff, ymargin+py*ydiff],'g');
        end
        
            
        %if we are plotting a target, increase it's life time by one
        if tlifetime>-1
            tlifetime = tlifetime + 1;
		elseif dlifetime > -1
            dlifetime = dlifetime + 1;
        end
        if glifetime > -1
            glifetime = glifetime +1;
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
    end
	if nargout == 1
		M = close(M);
	end

	function [dp,aa] = highlightSquare(dp,row,col,xdiff,ydiff)
        dp = fill([xmargin+(col-1)*xdiff, xmargin+col*xdiff, xmargin+col*xdiff, xmargin+(col-1)*xdiff],...
            [ymargin+row*ydiff, ymargin+row*ydiff, ymargin+(row-1)*ydiff, ymargin+(row-1)*ydiff],'w');
		set(dp,'Edgecolor','m','FaceAlpha',0,'LineWidth',2.0)
		if nargout == 2
			%annotate
			axPos = get(gca,'Position');
			xa(2) = axPos(1) + (((xmargin+col*xdiff))/screen_width)*axPos(3);
			xa(1) = axPos(1) + (((xmargin+(col+0.5)*xdiff))/screen_width)*axPos(3);

			ya(2) = axPos(2) + (((ymargin+row*ydiff))/screen_height)*axPos(3);
			ya(1) = axPos(2) + (((ymargin+(row+0.5)*ydiff))/screen_height)*axPos(3);
			aa = annotation('textarrow', xa, ya,'String','Decoded position');
		end
    end 

    function plot_locations()
        for i=1:size(locations,1)
                px = locations(i,2)-1;
                py = locations(i,1)-1;
                fill([xmargin+px*xdiff, xmargin+(px+1)*xdiff, xmargin+(px+1)*xdiff, xmargin+px*xdiff],...
            [ymargin+(rows-py)*ydiff, ymargin+(rows-py)*ydiff, ymargin+(rows-py-1)*ydiff, ymargin+(rows-py-1)*ydiff],[1.0, 0.8, 0.8]);
        end
    end
end
